require 'json'
require "kitchen-itamae/version"
require 'kitchen/provisioner/base'
require "kitchen/util"

module Kitchen
  module Provisioner
    class Itamae < Base
      # TODO: should not parasite chef
      default_config :parasite_chef_omnibus, true
      default_config :chef_omnibus_url, "https://www.chef.io/chef/install.sh"
      default_config :chef_omnibus_root, "/opt/chef"
      default_config :chef_omnibus_install_options, nil

      default_config :itamae_root, "kitchen"
      default_config :recipe_list, []
      default_config :node_json, nil
      default_config :sudo_command, 'sudo'
      default_config :with_ohai, false
      default_config :itamae_option, nil

      # (see Base#create_sandbox)
      def create_sandbox
        super
        FileUtils.cp_r(Dir.glob("kitchen/*"), sandbox_path)
      end

      # (see Base#init_command)
      def init_command
        cmd = "#{sudo("rm")} -rf #{config[:root_path]} ; mkdir -p #{config[:root_path]}"
        Util.wrap_command(cmd)
      end

      # (see Base#run_command)
      def run_command
        config.merge!(config[:config])
        debug(JSON.pretty_generate(config))
        runlist = config[:recipe_list].map do |recipe|
          cmd = ["cd #{config[:root_path]};", config[:sudo_command] , 'itamae']
          cmd << 'local'
          cmd << '--ohai' if config[:with_ohai]
          cmd << config[:itamae_option]
          cmd << "-j #{config[:node_json]}" if config[:node_json]
          cmd << recipe
          cmd.join(" ")
        end
        debug(runlist.join("\n"))
        Util.wrap_command(runlist.join("\n"))
      end


      # (see ChefBase#install_command)
      def install_command
        return unless config[:parasite_chef_omnibus]
        lines = [Util.shell_helpers, download_helpers, chef_helpers, chef_install_function, itamae_install_function]
        Util.wrap_command(lines.join("\n"))
      end

      private
      # (see ChefBase private)

      def download_helpers
        IO.read(
          Gem.find_files_from_load_path('../support/download_helpers.sh').first
        )
      end

      def chef_helpers
        IO.read(
          Gem.find_files_from_load_path('../support/chef_helpers.sh').first
        )
      end

      def chef_install_function
        version = config[:parasite_chef_omnibus].to_s.downcase
        pretty_version = case version
                         when "true" then "install only if missing"
                         when "latest" then "always install latest version"
                         else version
                         end
        install_flags = %w[latest true].include?(version) ? "" : "-v #{version}"
        if config[:chef_omnibus_install_options]
          install_flags << " " << config[:chef_omnibus_install_options]
        end
        <<-INSTALL_CHEF.gsub(/^ {10}/, "")
          if should_update_chef "#{config[:chef_omnibus_root]}" "#{version}" ; then
          echo "-----> Installing Chef Omnibus (#{pretty_version})"
          do_download #{config[:chef_omnibus_url]} /tmp/install.sh
                  #{sudo("sh")} /tmp/install.sh #{install_flags.strip}
          else
          echo "-----> Chef Omnibus installation detected (#{pretty_version})"
          fi
        INSTALL_CHEF
      end

      def itamae_install_function
        <<-INSTALL_ITAMAE
         cat <<EOL > /tmp/install_itamae.sh
         [ -f /usr/local/bin/itamae ] && exit
         /opt/chef/embedded/bin/gem install itamae --no-ri --no-rdoc
         ln -sf /opt/chef/embedded/bin/itamae /usr/local/bin/
EOL
         #{sudo("sh")} /tmp/install_itamae.sh
        INSTALL_ITAMAE
      end
    end
  end
end

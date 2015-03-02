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
      default_config :chef_omnibus_bin_dir, "/opt/chef/embedded/bin"
      default_config :chef_omnibus_install_options, nil

      default_config :itamae_root do |provisioner|
        provisioner.calculate_path("kitchen")
      end
      expand_path_for :itamae_root

      default_config :node_json, nil
      default_config :attributes, {}
      default_config :with_ohai, false
      default_config :itamae_option, nil
      default_config :use_bundler do |provisioner|
        config = provisioner.instance_variable_get(:@config)
        File.exists?(File.join(config[:itamae_root], 'Gemfile'))
      end

      # (see Base#create_sandbox)
      def create_sandbox
        super
        prepare_json
        FileUtils.cp_r(Dir.glob("#{config[:itamae_root]}/*"), sandbox_path)
      end

      # (see Base#init_command)
      def init_command
        cmd = []
        cmd << "#{sudo("rm")} -rf #{config[:root_path]} ; mkdir -p #{config[:root_path]}"
        debug("Cleanup Kitchen Root")
        Util.wrap_command(cmd.join("\n"))
      end

      # (see Base#init_command)
      def prepare_command
        return nil unless config[:use_bundler]
        debug("Prepare Bundler")
        cmd = ["cd #{config[:root_path]};"]
        cmd << "if [ -f Gemfile ] ;then"
        cmd << "#{sudo("/opt/chef/embedded/bin/bundle")} install --binstubs"
        cmd << "fi"
        Util.wrap_command(cmd.join("\n"))
      end

      # (see Base#run_command)
      def run_command
        debug(JSON.pretty_generate(config))
        lines = config[:run_list].map do |recipe|
          cmd = ["cd #{config[:root_path]} ;"]
          if config[:use_bundler]
            cmd << "export PATH=#{config[:chef_omnibus_bin_dir]}:$PATH ;"
            cmd << sudo("./bin/itamae")
          else
            cmd << sudo('/opt/chef/bin/itamae')
          end
          cmd << 'local'
          cmd << '--ohai' if config[:with_ohai]
          cmd << config[:itamae_option]
          cmd << "-j dna.json"
          if recipe.end_with?('.rb')
            cmd << recipe
          else
            cmd << "#{recipe}.rb"
          end
          cmd.join(" ")
        end
        debug(lines.join("\n"))
        Util.wrap_command(lines.join("\n"))
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
          #{sudo('chef-apply')} -e "chef_gem %Q{itamae} do action :upgrade end"
          ln -sf /opt/chef/embedded/bin/itamae /opt/chef/bin/itamae
EOL
          #{sudo("sh")} /tmp/install_itamae.sh
        INSTALL_ITAMAE
      end

      # (see ChefBase#prepare_json)
      def prepare_json
        dna = {}
        dna.merge!(JSON.parse(File.read(File.join(config[:itamae_root], config[:node_json])))) if config[:node_json]
        dna.rmerge!(config[:attributes])

        info("Preparing dna.json")
        debug("Creating dna.json from #{dna.inspect}")

        File.open(File.join(sandbox_path, "dna.json"), "wb") do |file|
          file.write(dna.to_json)
        end
      end
    end
  end
end

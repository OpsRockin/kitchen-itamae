require_relative '../../spec_helper'
require 'kitchen'

require 'kitchen/provisioner/itamae'

describe Kitchen::Provisioner::Itamae do
  let(:logger) { Logger.new(nil) }

  let(:provisioner) do
    Kitchen::Provisioner::Itamae.new(config).finalize_config!(instance)
  end

  let(:suite) do
    double(name: "test-default")
  end

  let(:instance) do
    double(name: "itamae_node", logger: logger, suite: suite)
  end

  let(:config) do
    { test_base_path: "/basist", kitchen_root: "/rooty", itamae_root: 'kitchen'  }
  end

  describe Kitchen::Provisioner::Itamae, "prepare_command" do
    it "returns nil prepare_command with default configration" do
      expect(provisioner.prepare_command).to be_nil
    end

    context "with Gemfile" do
      it "returns bundler prepare_command" do
        allow(File).to receive(:exists?).with(
          File.join(config[:kitchen_root], config[:itamae_root], 'Gemfile')
        ).and_return(true)
        expect(provisioner.prepare_command).to match regexify("bundle config shebang", :partial_line)
        expect(provisioner.prepare_command).to match regexify("bundle install --binstubs", :partial_line)
      end
    end
  end

  describe Kitchen::Provisioner::Itamae, "run_command" do
    it "returns run_command with recipe" do
      config[:run_list] = %w[tamatama itaita]
      expect(provisioner.run_command).to match regexify("tamatama.rb", :partial_line)
      expect(provisioner.run_command).to match regexify("itaita.rb", :partial_line)
    end

    context "with Gemfile" do
      it "returns bundler run_command" do
        config[:run_list] = %w[tamatama itaita]
        config[:use_bundler] = true
        allow(File).to receive(:exists?).with(
          File.join(config[:kitchen_root], config[:itamae_root], 'Gemfile')
        ).and_return(true)
        expect(provisioner.run_command).to match regexify("export PATH=", :partial_line)
        expect(provisioner.run_command).to match regexify("tamatama.rb", :partial_line)
        expect(provisioner.run_command).to match regexify("itaita.rb", :partial_line)
      end
    end
  end

  describe Kitchen::Provisioner::Itamae, "prepare_json" do
    before do
      @root = Dir.mktmpdir
      config[:kitchen_root] = @root
    end

    after do
      FileUtils.remove_entry(@root)
      begin
        provisioner.cleanup_sandbox
      rescue # rubocop:disable Lint/HandleExceptions
      end
    end

    let(:attrs) do
      JSON.parse(File.read(File.join(provisioner.sandbox_path, 'dna.json')))
    end

    it "creates dna.json to sandbox_path" do
      provisioner.create_sandbox
      provisioner.send(:prepare_json)
      expect(attrs).to be_empty
    end

    context "with Attributes" do
      it "creates dna.json with attributes" do
        config[:attributes] = {
          key: "value"
        }
        provisioner.create_sandbox
        provisioner.send(:prepare_json)
        expect(attrs['key']).to eq "value"
      end
    end
  end

  # see spec/provisioner/shell_spec
  def regexify(str, line = :whole_line)
    r = Regexp.escape(str)
    r = "^\s*#{r}$" if line == :whole_line
    Regexp.new(r)
  end
end

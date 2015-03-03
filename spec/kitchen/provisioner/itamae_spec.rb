require_relative '../../spec_helper'
require 'kitchen'

require 'kitchen/provisioner/itamae'

describe Kitchen::Provisioner::Itamae do
  let(:provisioner) do
    Kitchen::Provisioner.for_plugin("itamae", config)
  end

  let(:config) do
    {}
  end

end

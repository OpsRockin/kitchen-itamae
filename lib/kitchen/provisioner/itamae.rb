require 'json'
require "kitchen-itamae/version"
require 'kitchen/provisioner/base'

module Kitchen
  module Provisioner
    class Itamae < Base
       default_config :require_itamae_omnibus, false
       default_config :itmae_omnibus_url, nil

   end
  end
end

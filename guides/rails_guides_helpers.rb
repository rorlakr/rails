########################################
# overwritten by RORLAB
# apply locale to build documents.yml
########################################

require 'yaml'

module RailsGuides
  module Helpers
    def documents_by_section
      @documents_by_section ||= YAML.load_file(File.expand_path("../../guides/source/#{ENV["GUIDES_LANGUAGE"]}/documents.yaml", __FILE__))
    end
  end
end

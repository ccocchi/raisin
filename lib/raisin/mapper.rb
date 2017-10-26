require 'raisin/version_constraint'

module Raisin
  module Mapper
    def api(version, default: false)
      return unless block_given?

      version     = version.to_s
      raise 'Version is missing in constraint' if version.blank?
      constraint  = Raisin::VersionConstraint.new(version) unless default

      scope(module: version, constraints: constraint) do
        yield
      end
    end
  end
end

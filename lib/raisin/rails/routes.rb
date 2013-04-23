require 'raisin/routing'

module ActionDispatch::Routing
  class Mapper

    def api(options, &block)
      return unless block_given?

      version = options[:version].to_s
      is_default = options.fetch(:default, false)

      raise 'Version is missing in constraint' if version.blank?

      @api_resources = true

      send(:constraints, Raisin::Routing::VersionConstraint.new(version, is_default)) do
        send(:scope, module: version) do
          yield
        end
      end
    ensure
      @api_resources = nil
    end

    def resources(*resources, &block)
      if @api_resources
        options = resources.extract_options!
        options[:except] ||= []
        options[:except].concat([:new, :edit])
        super(*resources, options)
      else
        super
      end
    end

  end
end
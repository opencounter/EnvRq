module EnvRq
  class Requirement
    attr_reader :importance, :env_var, :options

    def initialize(importance, env_var, options={})
      @importance = importance
      @env_var = env_var
      @options = options
      @value = ENV[env_var]
    end

    VALIDATION_METHODS = [:enforce_present, :enforce_exclude, :enforce_type]
    def validate
      VALIDATION_METHODS.flat_map { |fn| self.public_send(fn) }.compact
    end

    def enforce_exclude
      ["should not be set."] if @options[:exclude] && !@value.nil?
    end

    def enforce_present
      ["is missing."] if @value.nil? && !@options[:exclude]
    end

    def enforce_type
      return unless type = @options[:type]

      err = case type
      when :int
        "#{@value} is not an integer." unless @value =~ /^\d+$/
      when :url
        "#{@value} is not a valid url." unless @value =~ /\/\/.+\..+/
      when :bool
        "#{@value} is not a boolean." unless @value == "true" || @value == "false"
      else
        raise '#{type} check is unimplemented'
      end

      puts err if err
      [err] unless err.nil?
    end
  end
end

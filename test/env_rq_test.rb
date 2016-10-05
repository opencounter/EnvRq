require 'test_helper'

class EnvRqTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::EnvRq::VERSION
  end

  def test_basic_require
    EnvRq.validate do |e|
      ENV['EXIST'] = 'true'
      e.warn("NOT_EXIST")
      e.warn("EXIST")
      e.handleIssues(:warn, lambda { |issues| assert issues.first[:requirement].env_var == 'NOT_EXIST' })
    end
  end

  def test_types
    EnvRq.validate do |e|
      ENV['INT'] = '123123'
      ENV['URL'] = 'https://test.com'
      ENV['SCHEMALESS_URL'] = '//test.com'
      ENV['BOOL'] = 'true'

      e.warn("INT", type: :int)
      e.warn("URL", type: :url)
      e.warn("SCHEMALESS_URL", type: :url)
      e.warn("BOOL", type: :bool)
      e.handleIssues(:warn, lambda { |issues| assert issues.empty? })
    end
  end

  def test_bad_types
    EnvRq.validate do |e|
      ENV['INT'] = '123123a'
      ENV['URL'] = 'test.com'
      ENV['SCHEMALESS_URL'] = '//test'
      ENV['BOOL'] = 'truthy'

      e.warn("INT", type: :int)
      e.warn("URL", type: :url)
      e.warn("SCHEMALESS_URL", type: :url)
      e.warn("BOOL", type: :bool)

      e.handleIssues(:warn, lambda { |issues| assert issues.length == 4 })
    end
  end

  def test_exclusions
    EnvRq.validate do |e|
      ENV['EXIST'] = 'true'
      e.fatal("EXIST", exclude: true)
      e.handleIssues(:fatal, lambda { |issues| assert issues.first[:requirement].env_var == 'EXIST' })
    end
  end
end

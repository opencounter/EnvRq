require "env_rq/version"

require 'env_rq/rq'
require 'env_rq/requirement'

module EnvRq
  def self.validate
    env_rq = Rq.new
    yield env_rq
    issues_by_severity = env_rq.issues.group_by { |i| i[:requirement].importance }
    Rq::ISSUE_LEVELS.reverse.each do |severity|
      issues = issues_by_severity[severity]
      next if issues.nil?

      Rq.print_issues(issues)
      env_rq.handlers[severity].call(issues) if env_rq.handlers.has_key?(severity)
    end
  end
end

class Rq
  attr_reader :issues, :handlers

  ISSUE_LEVELS = [:fatal, :warn, :info]

  def initialize
    @issues = []
    @handlers = {
      fatal: lambda { |issues| raise(StandardError.new("execution aborted due to ENV misconfiguration")) },
    }
  end

  def fatal(*args)
    rq(:fatal, *args)
  end

  def warn(*args)
    rq(:warn, *args)
  end

  def info(*args)
    rq(:info, *args)
  end

  def handleIssues(level, handler)
    @handlers[level] = handler
  end

  def self.print_issues(issues)
    issues.each do |issue|
      r = issue[:requirement]
      desc = r.options[:desc]
      desc = desc ? "(#{desc}) " : ""

      puts "#{r.env_var}#{desc}: #{issue[:msgs].join('')}"
    end
  end

  def rq(*args)
    requirement = Requirement.new(*args)
    msgs = requirement.validate()
    @issues.push({ requirement: requirement, msgs: msgs }) if msgs.any?
  end
end

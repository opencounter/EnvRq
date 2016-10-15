class Rq
  attr_reader :issues, :handlers

  ISSUE_LEVELS = [:fatal, :warn, :info]
  COLORS = { info: "\033[37m", warn: "\033[1;33m", fatal: "\033[31m" }

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

      puts "#{COLORS[r.importance]}#{r.env_var}#{desc}: #{issue[:msgs].join('')}\e[0m"
    end
  end

  def rq(*args)
    requirement = Requirement.new(*args)
    msgs = requirement.validate()
    @issues.push({ requirement: requirement, msgs: msgs }) if msgs.any?
  end
end

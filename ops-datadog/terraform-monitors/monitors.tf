resource "datadog_monitor" "cpu" {
  name                = "CPU"
  type                = "query alert"
  message             = "CPU usage high.\nHost name: {{host.name}}\nHost IP: {{host.ip}}\nEnvironment: {{host.env}}\nStack: {{host.stack}}\nLayer: {{host.role}} \nNotify: @pagerduty"
  query               = "avg(last_5m):abs( 100 - avg:system.cpu.idle{*} by {host} ) == 100"
  locked              = false
  new_host_delay      = 300
  no_data_timeframe   = 10
  notify_audit        = false
  notify_no_data      = false
  renotify_interval   = 60
  require_full_window = true
  timeout_h           = 60
  tags                = []
  thresholds {
    warning  = "99"
    critical = "100"
  }
}

resource "datadog_monitor" "disk" {
  name                = "Disk"
  type                = "query alert"
  message             = "Disk usage high.\nHost name: {{host.name}}\nHost IP: {{host.ip}}\nEnvironment: {{host.env}}\nStack: {{host.stack}}\nLayer: {{host.role}} \nNotify: @pagerduty"
  query               = "avg(last_1m):abs( avg:system.disk.free{!device:devtmpfs,!device:tmpfs} by {host} * 100 / avg:system.disk.total{!device:devtmpfs,!device:tmpfs} by {host} ) <= 10"
  locked              = false
  new_host_delay      = 300
  no_data_timeframe   = 10
  notify_audit        = false
  notify_no_data      = false
  renotify_interval   = 60
  require_full_window = true
  timeout_h           = 60
  tags                = []
  thresholds {
    warning  = "15"
    critical = "10"
  }
}

resource "datadog_monitor" "load" {
  name                = "Load"
  type                = "query alert"
  message             = "Load average high.\nHost name: {{host.name}}\nHost IP: {{host.ip}}\nEnvironment: {{host.env}}\nStack: {{host.stack}}\nLayer: {{host.role}}\nNotify: @pagerduty"
  query               = "avg(last_5m):abs(avg:system.load.norm.5{*} by {host}) > 4"
  locked              = false
  new_host_delay      = 300
  no_data_timeframe   = 10
  notify_audit        = false
  notify_no_data      = false
  renotify_interval   = 60
  require_full_window = true
  timeout_h           = 60
  tags                = []
  thresholds {
    warning  = "3.0"
    critical = "4.0"
  }
  
}

resource "datadog_monitor" "memory" {
  name                = "Memory"
  type                = "query alert"
  message             = "Low free memory.\nHost name: {{host.name}}\nHost IP: {{host.ip}}\nEnvironment: {{host.env}}\nStack: {{host.stack}}\nLayer: {{host.role}}\nNotify: @pagerduty"
  query               = "avg(last_1m):avg:system.mem.usable{*} by {host} <= 104857600"
  locked              = false
  new_host_delay      = 300
  no_data_timeframe   = 10
  notify_audit        = false
  notify_no_data      = false
  renotify_interval   = 60
  require_full_window = true
  timeout_h           = 60
  tags                = []
  thresholds {
    warning  = "208857600.0"
    critical = "104857600.0"
  }
}

resource "datadog_monitor" "swap" {
  name                = "Swap"
  type                = "query alert"
  message             = "Swap memory low.\nHost name: {{host.name}}\nHost IP: {{host.ip}}\nEnvironment: {{host.env}}\nStack: {{host.stack}}\nLayer: {{host.role}}\nNotify: @pagerduty"
  query               = "avg(last_1m):abs( avg:system.swap.free{*} by {host} * 100 / avg:system.swap.total{*} by {host} ) <= 5"
  locked              = false
  new_host_delay      = 300
  no_data_timeframe   = 10
  notify_audit        = false
  notify_no_data      = false
  renotify_interval   = 60
  require_full_window = true
  timeout_h           = 60
  tags                = []
  thresholds {
    warning  = "8"
    critical = "5"
  }
  
}

resource "datadog_monitor" "http" {
  name                = "HTTP"
  type                = "service check"
  message             = "HTTP ( {{url.name}} ) check failed.\nHost name: {{host.name}}\nHost IP: {{host.ip}}\nEnvironment: {{host.env}}\nStack: {{host.stack}}\nLayer: {{host.role}} \nNotify: @pagerduty"
  query               = "\"http.can_connect\".over(\"*\").by(\"host\",\"instance\",\"url\").last(5).count_by_status()"
  locked              = false
  new_host_delay      = 300
  no_data_timeframe   = 10
  notify_audit        = false
  notify_no_data      = false
  renotify_interval   = 60
  require_full_window = true
  timeout_h           = 60
  tags                = []
  thresholds {
    ok  = "1"
    critical = "4"
  }
  
}

resource "datadog_monitor" "process" {
  name                = "Process"
  type                = "service check"
  message             = "Process {{process.name}} failed.\nHost name: {{host.name}}\nHost IP: {{host.ip}}\nEnvironment: {{host.env}}\nStack: {{host.stack}}\nLayer: {{host.role}} \nNotify: @pagerduty"
  query               = "\"process.up\".over(\"*\").last(3).count_by_status()"
  locked              = false
  new_host_delay      = 300
  no_data_timeframe   = 10
  notify_audit        = false
  notify_no_data      = false
  renotify_interval   = 60
  require_full_window = true
  timeout_h           = 60
  tags                = []
  thresholds {
    ok       = "1"
    warning  = "1"
    critical = "2"
  }
  
}

resource "datadog_monitor" "tcp" {
  name                = "TCP"
  type                = "service check"
  message             = "TCP check failed.\nHost name: {{host.name}}\nHost IP: {{host.ip}}\nEnvironment: {{host.env}}\nStack: {{host.stack}}\nLayer: {{host.role}}\nNotify: @pagerduty"
  query               = "\"tcp.can_connect\".over(\"*\").by(\"host\",\"instance\",\"port\",\"target_host\").last(5).count_by_status()"
  locked              = false
  new_host_delay      = 300
  no_data_timeframe   = 10
  notify_audit        = false
  notify_no_data      = false
  renotify_interval   = 60
  require_full_window = true
  timeout_h           = 60
  tags                = []
  thresholds {
    ok  = "1"
    critical = "4"
  }
  
}
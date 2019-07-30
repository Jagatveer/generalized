resource "datadog_monitor" "memory" {
  name                = "[L2-Demo] Kubernetes Memory Usage"
  type                = "query alert"
  message             = "Memory usage high.\nHost name: {{host.name}}\nHost IP: {{host.ip}}\nEnvironment: {{host.env}}\nStack: {{host.stack}}\nLayer: {{host.role}} \n"
  query               = "avg(last_5m):avg:kubernetes.memory.usage{kube_deployment:goapp} > 5000000"
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
    warning  = "4000000"
    critical = "5000000"
  }
}

resource "datadog_monitor" "host_cpu" {
  name                = "[L2-Demo] Host CPU Usage"
  type                = "query alert"
  message             = "CPU usage high.\nHost name: {{host.name}}\nHost IP: {{host.ip}}\nEnvironment: {{host.env}}\nStack: {{host.stack}}\nLayer: {{host.role}} \n"
  query               = "avg(last_5m):avg:system.cpu.user{host:i-0f854016cb650b3a1} > 60"
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
    warning  = "30"
    critical = "60"
  }
}

resource "datadog_monitor" "app_requests" {
  name                = "[L2-Demo] Abnormal change in requests hits"
  type                = "event alert"
  message             = "Application service has an abnormal requests hit"
  query               = "avg(last_4h):anomalies(avg:trace.web.request.hits{env:none}.as_count(), 'basic', 2, direction='above', alert_window='last_15m', interval=60, count_default_zero='true') >= 1"
  locked              = false
  new_host_delay      = 300
  no_data_timeframe   = 10
  notify_audit        = false
  notify_no_data      = false
  renotify_interval   = 60
  timeout_h           = 60
  tags                = []
}


def file = new File(manager.build.workspace.remote, 'var.properties')
if(file.exists()) {
    file.readLines().each { line ->
        if(line.contains('=')) {
            def parts = line.split('=')
            if(parts.length == 2) {
                def key = parts[0].trim()
                def value = parts[1].trim()
                manager.envVars[key] = value
                manager.listener.logger.println("Injected variable ${key}=${value}")
            }
        }
    }
} else {
    manager.listener.logger.println("var.properties file not found at ${file.absolutePath}")
}
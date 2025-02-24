def file = new File(manager.build.workspace.remote, 'var.properties')
if(file.exists()) {
    file.readLines().each { line ->
        if(line.contains('=')) {
            def (key, value) = line.tokenize('=')
            manager.envVars[key.trim()] = value.trim()
            manager.listener.logger.println("Injected variable ${key.trim()}=${value.trim()}")
        }
    }
} else {
    manager.listener.logger.println("var.properties file not found at ${file.absolutePath}")
}
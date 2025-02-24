def build = Thread.currentThread().executable
def workspace = build.getEnvironment(TaskListener.NULL).get('WORKSPACE')
def file = new File(workspace + '/var.properties')

if(file.exists()) {
    file.readLines().each { line ->
        if(line.contains('=')) {
            def parts = line.split('=')
            if(parts.size() == 2) {
                def key = parts[0].trim()
                def value = parts[1].trim()
                build.addAction(new hudson.model.ParametersAction(new hudson.model.StringParameterValue(key, value)))
                println("Injected variable ${key}=${value}")
            }
        }
    }
} else {
    println("File not found at: ${file.absolutePath}")
}
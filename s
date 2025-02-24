import hudson.model.*
def build = Thread.currentThread().executable
def workspace = build.workspace.toString()
def file = new File(workspace, 'var.properties')

if(file.exists()) {
    file.readLines().each { line ->
        if(line.contains('=')) {
            def parts = line.split('=')
            if(parts.length == 2) {
                def key = parts[0].trim()
                def value = parts[1].trim()
                build.addAction(new ParametersAction(new StringParameterValue(key, value)))
                println("Injected variable ${key}=${value}")
            }
        }
    }
} else {
    println("File not found: ${file.absolutePath}")
}
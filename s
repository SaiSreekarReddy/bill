def props = new Properties()
File propsFile = new File(manager.build.workspace.remote + '/var.properties')
if(propsFile.exists()) {
    props.load(propsFile.newDataInputStream())
    props.each { key, value ->
        manager.envVars[key] = value
        manager.listener.logger.println("Injected variable ${key}=${value}")
    }
} else {
    manager.listener.logger.println("var.properties file not found at ${propsFile.absolutePath}")
}




Month: ${ENV, var="month"}
COF: ${ENV, var="cof"}
BCR: ${ENV, var="bcr"}
CRD: ${ENV, var="crd"}
SCC: ${ENV, var="scc"}
UCC: ${ENV, var="ucc"}
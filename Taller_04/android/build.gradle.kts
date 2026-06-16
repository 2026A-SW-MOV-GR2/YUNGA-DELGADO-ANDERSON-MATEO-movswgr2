allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Fuerza a todos los módulos (incluyendo plugins) a usar Java 17
subprojects {
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }

    // Configuración para tareas de Kotlin
    tasks.matching { it.name.contains("Kotlin") }.configureEach {
        try {
            // Usamos reflexión para configurar el jvmTarget sin depender de importaciones directas
            val kotlinOptions = this.property("kotlinOptions")
            val method = kotlinOptions?.javaClass?.getMethod("setJvmTarget", String::class.java)
            method?.invoke(kotlinOptions, "17")
        } catch (e: Exception) {
            // Si la tarea no es de tipo KotlinCompile, se ignora
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

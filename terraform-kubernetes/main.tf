resource "kubernetes_deployment_v1" "nginx" {
    metadata {
        name      = "nginx-deployment"
        namespace = "default"
        labels = {
        app = "nginx"
        }
    }
    
    spec {
        replicas = 2
    
        selector {
        match_labels = {
            app = "nginx"
        }
        }
    
        template {
            metadata {
                labels = {
                app = "nginx"
                }
        }
    
        spec {
            container {
                name  = "nginx"
                image = "nginx:latest"
        
                port {
                    container_port = 80
                }
            }
        }
        }
    }
}

resource "kubernetes_service_v1" "nginx_service" {
    metadata {
        name      = "nginx-service"
        namespace = "default"
    }
    
    spec {
        selector = {
            app = "nginx"
        }
    
        port {
            port        = 80
            target_port = 80
        }
    
        type = "NodePort"
    }
  
}
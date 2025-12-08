# C4 Model for **paytrackr**

Below is a full C4 representation (Levels 1–3) of the `paytrackr` infrastructure and application architecture, using Mermaid's C4 syntax.

---

## **C4 Level 1 – System Context**

```mermaid
C4Context
    title System Context - paytrackr

    Person(user, "End User", "Uses the paytrackr application")

    System(paytrackr, "paytrackr App", "Tracks and manages payments")

    System_Ext(azure, "Azure Cloud", "Cloud platform hosting the app and database")

    Rel(user, paytrackr, "Uses via web/API")
    Rel(paytrackr, azure, "Runs on infrastructure in")
```

---

## **C4 Level 2 – Container Diagram**

```mermaid
C4Container
    title Container Diagram - paytrackr

    Person(user, "End User")

    System_Boundary(paytrackr, "paytrackr System") {
        Container(app, "paytrackr API/App", "Containerized .NET/Node/etc.", "Runs inside AKS and provides application functionality")
        ContainerDb(db, "PostgreSQL DB", "Azure PostgreSQL Flexible Server", "Stores application data; private network only")
        Container(kv, "Key Vault", "Azure Key Vault", "Stores secrets such as connection strings")
    }

    System_Ext(aks, "Azure Kubernetes Service", "Runs the containerized application")
    System_Ext(dns, "Private DNS Zone", "Resolves DB hostname to private IP")

    Rel(user, app, "Interacts with via HTTPS (Load Balancer)")
    Rel(app, db, "Reads/writes using private endpoint")
    Rel(app, kv, "Reads secrets via managed identity")
    Rel(app, dns, "Resolves DB hostname")
```

---

## **C4 Level 3 – Component Diagram (Inside AKS)**

```mermaid
C4Component
    title Component Diagram - paytrackr App inside AKS

    Container_Boundary(aks, "AKS Cluster") {
        Component(api, "paytrackr API", ".NET/Node App", "Main application logic")
        Component(cfg, "ConfigMap", "K8s ConfigMap", "Non-sensitive configuration data")
        Component(sec, "Secret", "K8s Secret", "Sensitive configuration (env vars, tokens)")
        Component(lb, "Service: LoadBalancer", "K8s Service", "Exposes the app externally via public IP")
    }

    ComponentDb(db, "PostgreSQL Database", "Azure PostgreSQL Flexible Server")
    Component(kv, "Azure Key Vault", "Secret Storage")
    Component(dns, "Azure Private DNS Zone", "DNS Resolution for DB")

    Rel(api, cfg, "Reads configuration")
    Rel(api, sec, "Reads secrets")
    Rel(api, kv, "Fetches postgres connection string via kubelet identity")
    Rel(api, db, "Connects over private network")
    Rel(api, dns, "Resolves DB hostname → private IP")
    Rel(lb, api, "Routes HTTPS traffic")
```

---

If you want, I can also generate:

* **C4 Level 4 (Code/Module)** diagram
* A **single combined high‑level C4 poster**
* A **rendered PNG/SVG** version via mermaid
* A **cleaned-up version for documentation or Terraform repo**

Just tell me!

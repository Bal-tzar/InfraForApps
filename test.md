# InfraForApps UML Diagram for **paytrackr**

```mermaid
graph TD
    A[Azure Subscription]
    A --> B[paytrackr-rg (Resource Group)]

    %% VNet and Subnets
    B --> C[paytrackr-aks-vnet (10.0.0.0/16)]
    C --> D[aks-subnet (10.0.1.0/24)]
    C --> E[postgres-subnet (10.0.2.0/24)\nDelegated to PostgreSQL]

    %% AKS Cluster
    D --> F[paytrackr-aks (AKS Cluster)]
    F --> F1[Node Pool: default\nStandard_B2s x3]
    F --> F2[Managed Identity (Kubelet)]

    %% Private DNS
    B --> G[Private DNS Zone:\npaytrackr.postgres.database.azure.com]
    G --> G1[VNet Link → paytrackr-aks-vnet]

    %% PostgreSQL
    B --> H[PostgreSQL Flex Server\npaytrackr-aks-postgres (v16)]
    H --> H1[Database: paytrackr\nPrivate Access Only]

    %% Key Vault
    B --> I[Key Vault: paytrackr-aks-kv]
    I --> I1[Secret: postgres-connection-string]
    I --> I2[Access Policies:\n• User/SP: full\n• AKS kubelet: read]

    %% Kubernetes Namespace
    F --> J[Namespace: paytrackr]
    J --> J1[Deployment: paytrackr app]
    J1 --> J2[Pods / Container: dockerhubuser/paytrackr]
    J --> J3[ConfigMap]
    J --> J4[Secret]
    J --> J5[Service: LoadBalancer → EXTERNAL-IP]

    %% Networking Flow
    J2 -->|resolves DB host| G
    G -->|returns private IP| E
    J2 -->|connects to| H
```

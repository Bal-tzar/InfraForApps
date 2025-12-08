flowchart TD

    subgraph Azure["Azure Subscription"]
        
        subgraph RG["paytrackr-rg (Resource Group)"]

            subgraph VNET["paytrackr-aks-vnet (10.0.0.0/16)"]
                subgraph AKSSubnet["aks-subnet (10.0.1.0/24)"]
                    AKS["AKS Cluster: paytrackr-aks"]
                end

                subgraph PGSubnet["postgres-subnet (10.0.2.0/24)"]
                    Postgres["PostgreSQL Flexible Server\npaytrackr-aks-postgres"]
                end
            end

            DNS["Private DNS Zone\npaytrackr.postgres.database.azure.com"]
            KV["Key Vault\npaytrackr-aks-kv"]

        end
    end

    %% Traffic & Relations
    App["paytrackr App (Pods)"]

    AKS --> App
    App --> DNS
    DNS --> Postgres
    App --> Postgres
    App --> KV

    KV -->|"Secret: postgres-connection-string"| App

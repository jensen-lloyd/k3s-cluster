#!/bin/bash
set -Eeuo pipefail

NAMESPACE="immich"
BASE="/primaryPool/apps/immich"

echo ""
echo "============================================"
echo "          IMMICH COMPLETE RESET"
echo "============================================"
echo ""
echo "THIS WILL PERMANENTLY DELETE:"
echo "  $BASE/data"
echo "  $BASE/machine-learning"
echo "  $BASE/postgres"
echo ""
read -rp "Type RESET to continue: " CONFIRM

if [[ "$CONFIRM" != "RESET" ]]; then
    echo "Cancelled."
    exit 1
fi

# Safety checks
[[ "$BASE" == "/primaryPool/apps/immich" ]] || exit 1
[[ -d "$BASE" ]] || {
    echo "ERROR: Immich storage directory not found."
    exit 1
}

for DIR in data machine-learning postgres; do
    [[ ! -L "$BASE/$DIR" ]] || {
        echo "ERROR: $BASE/$DIR is a symlink."
        exit 1
    }
done

echo ""
echo "[1/7] Stopping all Immich deployments..."

for DEPLOYMENT in immich-server immich-ml postgres redis; do
    kubectl scale deployment "$DEPLOYMENT" \
        -n "$NAMESPACE" --replicas=0
done

echo "Waiting for pods to terminate..."

TIMEOUT=$((SECONDS + 180))

while kubectl get pods -n "$NAMESPACE" -o json |
    jq -e '.items | length > 0' >/dev/null; do

    if (( SECONDS >= TIMEOUT )); then
        echo "ERROR: Pods did not terminate."
        exit 1
    fi

    sleep 2
done

echo ""
echo "[2/7] Deleting old Immich directories..."

rm -rf --one-file-system \
    "$BASE/data" \
    "$BASE/machine-learning" \
    "$BASE/postgres"

echo ""
echo "[3/7] Recreating directories..."

mkdir -p \
    "$BASE/data" \
    "$BASE/machine-learning" \
    "$BASE/postgres"

# Marker files ONLY in data and machine-learning
touch "$BASE/data/.immich"
touch "$BASE/machine-learning/.immich"

echo ""
echo "[4/7] Applying ownership and permissions..."

chown -R 1000:1000 "$BASE/data"
chmod 775 "$BASE/data"
chmod 664 "$BASE/data/.immich"

chown -R 1000:1000 "$BASE/machine-learning"
chmod 775 "$BASE/machine-learning"
chmod 664 "$BASE/machine-learning/.immich"

chown -R 999:999 "$BASE/postgres"
chmod 700 "$BASE/postgres"

echo ""
echo "[5/7] Starting PostgreSQL..."

kubectl scale deployment postgres \
    -n "$NAMESPACE" --replicas=1

echo "Waiting for PostgreSQL pod..."

TIMEOUT=$((SECONDS + 180))

while true; do
    POD=$(kubectl get pods -n "$NAMESPACE" \
        -l app=postgres \
        -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)

    if [[ -n "$POD" ]]; then
        READY=$(kubectl get pod "$POD" -n "$NAMESPACE" \
            -o jsonpath='{.status.containerStatuses[0].ready}' \
            2>/dev/null || true)

        if [[ "$READY" == "true" ]]; then
            break
        fi

        PHASE=$(kubectl get pod "$POD" -n "$NAMESPACE" \
            -o jsonpath='{.status.phase}' 2>/dev/null || true)

        if [[ "$PHASE" == "Failed" ]]; then
            echo "ERROR: PostgreSQL pod failed."
            kubectl logs "$POD" -n "$NAMESPACE" --tail=100
            exit 1
        fi
    fi

    if (( SECONDS >= TIMEOUT )); then
        echo "ERROR: PostgreSQL did not become ready."
        [[ -n "$POD" ]] && kubectl logs "$POD" \
            -n "$NAMESPACE" --tail=100 || true
        exit 1
    fi

    sleep 3
done

echo "PostgreSQL pod is ready."

# Verify PostgreSQL accepts connections
echo "Checking PostgreSQL readiness..."

TIMEOUT=$((SECONDS + 120))

until kubectl exec "$POD" -n "$NAMESPACE" \
    -- pg_isready >/dev/null 2>&1; do

    if (( SECONDS >= TIMEOUT )); then
        echo "ERROR: PostgreSQL is not accepting connections."
        kubectl logs "$POD" -n "$NAMESPACE" --tail=100
        exit 1
    fi

    sleep 3
done

echo "PostgreSQL is accepting connections."

echo ""
echo "[6/7] Starting Machine Learning and Redis..."

kubectl scale deployment immich-ml \
    -n "$NAMESPACE" --replicas=1

kubectl scale deployment redis \
    -n "$NAMESPACE" --replicas=1

kubectl rollout status deployment/immich-ml \
    -n "$NAMESPACE" --timeout=180s

kubectl rollout status deployment/redis \
    -n "$NAMESPACE" --timeout=180s

echo "Waiting 30 seconds..."
sleep 30

echo ""
echo "[7/7] Starting Immich server..."

kubectl scale deployment immich-server \
    -n "$NAMESPACE" --replicas=1

kubectl rollout status deployment/immich-server \
    -n "$NAMESPACE" --timeout=300s

echo ""
echo "============================================"
echo "          IMMICH RESET COMPLETE"
echo "============================================"
echo ""

kubectl get deployments,pods -n "$NAMESPACE"

echo ""
echo "Storage:"
ls -lah "$BASE"

echo ""
echo "Next steps:"
echo "1. Copy your photo/video library into data/upload."
echo "2. Restore your database using Immich's built-in tool."
echo ""

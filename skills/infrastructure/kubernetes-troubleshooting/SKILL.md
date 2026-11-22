---
name: kubernetes-troubleshooting
description: Systematically diagnose Kubernetes and OpenShift problems using a progressive methodology — gather facts, establish scope, identify failure domains, test hypotheses, find root cause, and recommend remediation — preferring read-only commands and clearly flagging any that modify cluster state or expose secrets.
---

# Kubernetes Troubleshooting

## Purpose

Provide a repeatable, read-only-first methodology for diagnosing problems in
Kubernetes and OpenShift clusters, driving toward **root cause** rather than
reflexive restarts. It works across standard Kubernetes and adds OpenShift
specifics where useful.

## When to use this skill

- A workload is failing, degraded, unreachable, or behaving unexpectedly.
- Pods are crash-looping, pending, or not ready; a service has no endpoints;
  networking/DNS/ingress is misbehaving.
- You need a structured diagnosis, not a guess.

## When NOT to use this skill

- The problem is clearly application-level and reproducible outside the cluster.
- You lack any read access to the cluster (obtain access first).

## Inputs and prerequisites

- A kubectl (and/or `oc` for OpenShift) context with at least read access.
- The reported symptom and, ideally, when it started and what changed.
- Do **not** assume every environment has the same tools, permissions, CRDs,
  networking implementation (CNI), or ingress/Gateway stack.

Check what you have before relying on it:

```bash
kubectl config current-context
kubectl auth can-i get pods -n <namespace>
command -v oc >/dev/null && echo "oc available (OpenShift)"
```

## Workflow (progressive methodology)

> Prefer read-only diagnostics first. Commands that **change cluster state** are
> marked ⚠️ and require explicit user approval.

### 1. Gather facts — understand the symptom

Capture the exact symptom, when it began, blast radius, and recent changes
(deploys, config, scaling, node events). Restate it before digging in.

### 2. Establish the scope

Pin down the affected cluster, namespace, workload, and resources:

```bash
kubectl config current-context
kubectl get ns
kubectl get all -n <namespace>
kubectl get events -n <namespace> --sort-by=.lastTimestamp | tail -n 30
```

### 3. Identify likely failure domains

Inspect the relevant resources to localize the fault.

**Pods / workloads:**

```bash
kubectl get pods -n <ns> -o wide
kubectl describe pod <pod> -n <ns>        # events, probes, restart reasons
kubectl logs <pod> -n <ns> [-c <container>] [--previous]
kubectl get deploy,rs,sts,ds -n <ns>
```

Look at: `STATUS`/`READY`, restart counts, `CrashLoopBackOff`, `ImagePullBackOff`,
`OOMKilled`, probe failures, and `Pending` (scheduling) reasons in events.

**Scheduling & resource constraints:**

```bash
kubectl describe node <node>              # allocatable vs allocated, taints
kubectl top pod -n <ns>                   # needs metrics-server (may be absent)
kubectl top node                          # needs metrics-server
kubectl get pod <pod> -n <ns> -o jsonpath='{.spec.containers[*].resources}'
```

Check requests/limits vs availability, taints/tolerations, node selectors,
affinity, and `Pending` events like `Insufficient cpu/memory` or
`FailedScheduling`.

**Networking, DNS, services & endpoints:**

```bash
kubectl get svc -n <ns>
kubectl get endpoints <svc> -n <ns>       # empty endpoints => selector/readiness issue
kubectl get endpointslices -n <ns>
# DNS check from inside the cluster:
kubectl run netcheck --rm -it --image=busybox:1.36 --restart=Never -n <ns> -- \
  nslookup <svc>.<ns>.svc.cluster.local     # ⚠️ creates a temporary pod — approval
```

For ingress / Gateway API (presence varies — verify before assuming):

```bash
kubectl get ingress -n <ns>
kubectl get gateway,httproute -A 2>/dev/null   # Gateway API CRDs may be absent
```

**Configuration, secrets references & service accounts (without exposing secret values):**

```bash
kubectl get configmap -n <ns>
kubectl describe configmap <cm> -n <ns>
# Confirm a secret EXISTS and is referenced — do NOT decode its data:
kubectl get secret <secret> -n <ns>                 # shows keys/metadata only
kubectl get pod <pod> -n <ns> -o jsonpath='{.spec.serviceAccountName}'
kubectl get sa -n <ns>
```

> ⚠️ Never run `kubectl get secret ... -o yaml` and decode values, and never
> print secret contents. Confirm existence and references only.

**Operator-managed / custom resources:**

```bash
kubectl get crd | grep -i <keyword>
kubectl get <customresource> -n <ns>
kubectl describe <customresource>/<name> -n <ns>   # status conditions, messages
```

Remember operators may **reconcile/overwrite** manual edits — treat the custom
resource (not the managed child objects) as the source of truth.

**OpenShift-specific considerations (when `oc` is present):**

```bash
oc get routes -n <ns>                     # OpenShift Routes (instead of Ingress)
oc get projects
oc adm policy who-can get pods -n <ns>     # SCC/RBAC context
oc get clusteroperators                    # platform-level health
# Note: SecurityContextConstraints (SCC) often cause pod admission/permission issues.
```

### 4. Test hypotheses

Form specific, falsifiable hypotheses from the evidence (e.g. "readiness probe
failing → endpoints empty → service unreachable") and test each with the least
invasive check. Prefer read-only verification before any change.

### 5. Determine root cause

Identify the underlying cause, not just a symptom. "Restarting fixes it" is a
mitigation, not a root cause — explain *why* it failed.

### 6. Recommend remediation

Produce a concise diagnosis and a recommended fix. Clearly separate:

- **Read-only** confirmations.
- ⚠️ **State-changing** actions requiring explicit approval, e.g.:

  ```bash
  kubectl rollout restart deploy/<name> -n <ns>      # ⚠️ restarts workload
  kubectl scale deploy/<name> --replicas=<n> -n <ns> # ⚠️ changes capacity
  kubectl apply -f <fix>.yaml                         # ⚠️ mutates cluster state
  kubectl delete pod <pod> -n <ns>                    # ⚠️ deletes a pod
  ```

### 7. Verify recovery

After an approved change, confirm the fix resolved the issue and did not regress
anything:

```bash
kubectl get pods -n <ns> -w            # watch until Ready/stable
kubectl get events -n <ns> --sort-by=.lastTimestamp | tail -n 20
kubectl get endpoints <svc> -n <ns>    # endpoints populated again?
```

## Validation and expected outcomes

- A written diagnosis stating the root cause and the evidence for it.
- A remediation recommendation with read-only vs state-changing steps separated.
- After an approved fix, verification showing the symptom is resolved.

## Error handling

- **Permission denied / `cannot list/get`** — note the missing RBAC and work
  within available access; report what could not be checked.
- **`metrics-server`/`top` unavailable** — fall back to `describe` and events.
- **CRD not found** (e.g. Gateway API) — the feature isn't installed; adjust the
  investigation accordingly.
- If evidence is inconclusive, state what additional access or logs are needed
  rather than guessing.

## Safety considerations

- **Read-only first.** All diagnostic commands above are read-only except those
  marked ⚠️ (temporary pod creation and all of step 6).
- ⚠️ State-changing commands require **explicit user approval**; never apply them
  autonomously.
- **Never expose secret values.** Inspect existence/references only.
- Do not assume uniform tooling, permissions, CRDs, or networking across
  environments — verify before relying on a capability.

## Examples

**Symptom:** "Service returns connection refused."

1. Facts: started after a new deploy.
2. Scope: namespace `shop`, service `cart`.
3. `kubectl get endpoints cart -n shop` → **no endpoints**.
   `kubectl get pods -n shop` → pods `Running` but `0/1 READY`.
   `kubectl describe pod` → readiness probe failing on `/healthz` (404).
4. Hypothesis: new image changed the health path → probe fails → pod not Ready →
   endpoints empty → service unreachable. Confirmed by probe config vs app route.
5. Root cause: readiness probe path mismatch after the deploy (not a network
   fault).
6. Remediation: fix the probe path (or app route). ⚠️ `kubectl apply` the
   corrected Deployment — requires approval.
7. Verify: pods go `1/1 READY`, `endpoints cart` populated, service responds.

## Dependencies and compatibility notes

- Requires `kubectl`; `oc` for OpenShift specifics; `metrics-server` for `top`
  (optional). Gateway API and various CRDs are environment-dependent.
- No agent-specific dependencies; portable to any runtime that can run shell
  commands against the cluster.
- Mark anything environment-specific (CNI, ingress controller, SCCs) as requiring
  verification in the target cluster.

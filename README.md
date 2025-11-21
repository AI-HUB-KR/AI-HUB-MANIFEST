# AI-HUB Helm 차트

AI-HUB 프로젝트의 네임스페이스, CloudNativePG(PostgreSQL) 클러스터, Spring / Nest 애플리케이션을 하나의 Helm 차트로 배포합니다.  
이 리포지토리는 ArgoCD가 감시하는 GitOps 소스 저장소로 사용됩니다.

## 사전 준비
- kubectl
- Helm 3.x 이상
- 대상 클러스터에 CloudNativePG CRD 설치 (필수)

## 구조
- `Chart.yaml`: 차트 메타데이터
- `values.yaml`: 네임스페이스 / DB / 애플리케이션 기본값
- `templates/`: Helm 템플릿(네임스페이스, 데이터베이스, Spring, Nest)

## ArgoCD 연동
ArgoCD Application이 이 리포지토리와 브랜치를 감시하면서 Helm 차트를 렌더링해 배포합니다. 예시는 아래와 같습니다.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ai-hub
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/AI-HUB-KR/AI-HUB-MANIFEST.git
    targetRevision: main
    path: .
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: ai-hub
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### GitOps 플로우
1. `values.yaml` 혹은 템플릿을 수정하고 커밋/푸시합니다.
2. ArgoCD가 변경 사항을 감지해 차트를 렌더링하고 `ai-hub` 네임스페이스에 적용합니다.
3. `argocd app get ai-hub`, `argocd app history ai-hub`, `argocd app diff ai-hub` 명령으로 상태를 점검합니다.
4. 필요 시 `argocd app sync ai-hub`로 강제 동기화할 수 있습니다.

### 환경별 값 관리
- 기본값은 `values.yaml`에 정의되어 있으며, 환경별 파일을 추가한 뒤 Application의 `helm.valueFiles`에 여러 파일을 지정할 수 있습니다.
- 혹은 브랜치/디렉터리 단위로 Application을 나누어 각 환경을 독립적으로 관리할 수 있습니다.

## CloudNativePG 시크릿 관리
- `templates/01-database.yaml`에서 생성되는 CloudNativePG `Cluster`는 `my-db-app`(애플리케이션 접속용), `my-db-superuser`, `my-db-repl` 등의 시크릿을 자동 생성하고 로테이션합니다.
- Spring / Nest 애플리케이션 템플릿은 `values.database.appSecret.*` 값을 통해 CNPG가 만든 시크릿을 참조합니다. 기본 설정에서는 `username`, `password` 키를 사용합니다.
- DB 자격 증명이 바뀌면 CNPG가 시크릿을 갱신하므로, 애플리케이션 파드가 재시작되도록 `kubectl rollout restart` 또는 ArgoCD Sync를 실행해 주세요.
- 반대로 `my-app-secrets`와 같은 비DB 시크릿은 수동으로 생성·관리해야 합니다(예: 다른 서비스 비밀번호).

## 주의 사항
- CloudNativePG가 `my-db-app` 등 DB 시크릿을 자동 생성하므로 이름을 임의 변경하거나 수동으로 롤백하지 마세요. 단, `my-app-secrets`처럼 다른 애플리케이션 시크릿은 별도로 생성해야 합니다.
- `values.yaml`의 이미지 이름/레플리카/리소스/서비스 타입 등은 환경에 맞게 조정하세요.
- ArgoCD 자동 Sync를 사용 중이라면 수동으로 클러스터 리소스를 수정하지 말고 반드시 Git에 변경 사항을 반영하세요.

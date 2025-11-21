# AI-HUB Helm 차트

AI-HUB 프로젝트의 네임스페이스, CloudNativePG(PostgreSQL) 클러스터, Spring / Nest 애플리케이션을 하나의 Helm 차트로 배포할 수 있도록 구성했습니다.

## 사전 준비
- kubectl
- Helm 3.x 이상
- 대상 클러스터에 CloudNativePG CRD 설치 (필수)

## 구조
- `Chart.yaml`: 차트 메타데이터
- `values.yaml`: 네임스페이스 / DB / 애플리케이션 기본값
- `templates/`: Helm 템플릿(네임스페이스, 데이터베이스, Spring, Nest)

## 사용 방법
1. 값 커스터마이징  
   `values.yaml`을 직접 수정하거나 환경별 Values 파일을 만들어 `-f custom-values.yaml` 옵션으로 적용합니다.
2. 렌더링 확인  
   ```sh
   helm template ai-hub . -n ai-hub
   ```
3. 배포  
   ```sh
   helm install ai-hub . -n ai-hub --create-namespace
   ```
4. 변경 배포  
   ```sh
   helm upgrade ai-hub . -n ai-hub
   ```

## 주의 사항
- 시크릿(`my-db-app`, `my-app-secrets`)은 미리 생성되었다고 가정합니다.
- `values.yaml`의 이미지 이름/레플리카/리소스/서비스 타입 등은 환경에 맞게 조정하세요.


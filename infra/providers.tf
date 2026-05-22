provider "aws" {
  region = "ap-northeast-2"

  default_tags {
    tags = {
      team    = "team-2"       # 본인 팀명으로 변경
      project = "resource-opt" # 프로젝트명
      env     = "dev"          # 환경 (dev/prod)
    }
  }
}

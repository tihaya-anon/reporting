#import "../../diatypst/lib.typ": vis-slides

#show: vis-slides.with(
  title: "DataAgent 建设推进复盘",
  subtitle: "基于 2026-05-12 至 2026-07-24 工作日志的阶段性整理",
  date: "2026-07-24",
  authors: ("Data Agent",),
  toc: true,
)

#include "sections/00-overview.typ"
#include "sections/01-cicd-iac.typ"
#include "sections/02-release-rollback.typ"
#include "sections/03-cache-pyramid.typ"
#include "sections/04-dagster-metadata-plane.typ"
#include "sections/05-async-hooks.typ"
#include "sections/06-open-questions.typ"

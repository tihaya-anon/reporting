#import "../../diatypst/lib.typ": vis-slides

#show: vis-slides.with(
  title: "DataAgent agent 使用指引",
  subtitle: "给技术和业务团队的工程操作约定",
  date: "2026-07-24",
  authors: ("Data Agent",),
  toc: true,
)

#include "sections/00-overview.typ"
#include "sections/01-cicd-iac.typ"
#include "sections/03-cache-pyramid.typ"
#include "sections/02-release-rollback.typ"
#include "sections/04-dagster-metadata-plane.typ"
#include "sections/05-async-hooks.typ"
#include "sections/06-summary.typ"

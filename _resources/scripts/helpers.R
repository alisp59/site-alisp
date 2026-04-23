glue_qmd <- \(x, .envir = parent.frame()) {
  stringr::str_glue(x, .open = "<<", .close = ">>", .envir = .envir)
}

social_icon <- \(id, icon, title = id, set = "fa6-brands") {
  glue_qmd(
    "
    <a
      href='{{< var social.<<id>>.href >}}'
      title='<<title>>'
      aria-label='<<title>>'
      target='_blank'
      rel='noopener'>
      <iconify-icon
        icon='<<set>>:<<icon>>'
        width='1.5em'
        height='1.5em'
        aria-hidden='true'>
      </iconify-icon>
    </a>
  "
  )
}

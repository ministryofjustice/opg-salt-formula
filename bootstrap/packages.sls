# These are common packages that are installed on all machines. Avoid placing
# development tools and extra documentation here - use module.devel for example


nano:
  pkg:
    - installed

unzip:
  pkg:
    - installed

cron:
  pkg:
    - name: cron
    - installed
    - order: 0

htop:
  pkg:
    - installed

screen:
  pkg:
    - installed

pigz:
  pkg:
    - installed

telnet:
  pkg:
    - installed

mg:
  pkg:
    - installed


bootstrap_pkgs:
  pkg:
    - installed
    - pkgs:
      - git
      - emacs23-nox
      - joe

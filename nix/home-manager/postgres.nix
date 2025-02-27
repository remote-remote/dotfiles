{ pkgs, username, ... }:
{
  home = {
    packages = with pkgs; [
      postgresql_15
    ];

    sessionVariables = {
      PGDATA = "$HOME/.postgres-dev/data";
      PGHOST = "$HOME/.postgres-dev";
      PGPORT = "5432";
    };
  };

  programs.zsh = {
    shellAliases = {
      pg-start = ''
            if ! ${pkgs.postgresql_15}/bin/pg_ctl -D "$PGDATA" status >/dev/null 2>&1; then
              mkdir -p "$PGDATA" "$PGHOST"
              if [ ! -f "$PGDATA/PG_VERSION" ]; then
                ${pkgs.postgresql_15}/bin/initdb -D "$PGDATA" --auth=trust
                ${pkgs.postgresql_15}/bin/pg_ctl -D "$PGDATA" -o "-k $PGHOST" -l "$PGHOST/pg.log" start
                sleep 1
                ${pkgs.postgresql_15}/bin/psql -U ${username} -d postgres -c "CREATE ROLE ${username} WITH LOGIN SUPERUSER CREATEDB;"
                ${pkgs.postgresql_15}/bin/pg_ctl -D "$PGDATA" stop
              fi
              ${pkgs.postgresql_15}/bin/pg_ctl -D "$PGDATA" -o "-k $PGHOST" -l "$PGHOST/pg.log" start
              echo "PostgreSQL started at $PGHOST:$PGPORT with user ${username}"
            else
              echo "PostgreSQL already running at $PGHOST:$PGPORT"
            fi
      '';
      pg-stop = ''
            if ${pkgs.postgresql_15}/bin/pg_ctl -D "$PGDATA" status >/dev/null 2>&1; then
              ${pkgs.postgresql_15}/bin/pg_ctl -D "$PGDATA" stop
              echo "PostgreSQL stopped"
            else
              echo "PostgreSQL not running"
            fi
      '';
    };
  };
}

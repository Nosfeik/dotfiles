# Firewall

Uso UFW con lo básico: deny incoming, allow outgoing, deny routed y logging en low. No tengo puertos abiertos ni reglas propias.

| Ajuste | Valor |
|---|---|
| `/etc/ufw/ufw.conf` | `ENABLED=yes`, `LOGLEVEL=low` |
| IPv6 | `yes` |
| INPUT / OUTPUT / FORWARD | `DROP` / `ACCEPT` / `DROP` |

Para revisar cómo está:

```bash
sudo ufw status verbose
sudo ufw show added
systemctl is-enabled ufw.service
```

## Activarlo en una instalación nueva

Instalar el paquete no prende UFW. Lo hago desde una TTY, ya con la red configurada:

```bash
./scripts/firewall.sh           # enseña lo que va a hacer
./scripts/firewall.sh --apply
```

El script no corre por SSH ni fuera de una TTY local, y se detiene si encuentra reglas propias o cambios en las reglas base del paquete. Si todo está limpio respalda `/etc/ufw` y `/etc/default/ufw`, aplica las políticas, hace `ufw enable` y habilita el servicio. El filtrado empieza desde `ufw enable`, no hace falta reiniciar. No uso `ufw reset` ni `--force`.

Si se corta antes del último paso, revisar el estado y hacer `sudo systemctl enable ufw.service` a mano.

No guardo `iptables-save`, `nft list ruleset` ni reglas que meten Docker o las VPN. `before.rules` y `after.rules` son los del paquete.

## Pendiente

Docker, Exegol, VMs y VPNs meten sus propias reglas y forwarding. Eso lo voy a revisar cuando configure esa parte, por ahora no agregué nada.

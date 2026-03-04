#!/bin/sh
# ImmortalWrt/OpenWrt-compatible MOTD sysinfo (x86_64 friendly)
# - Avoid luci-specific ubus calls (no conflict)
# - Use standard OpenWrt/ImmortalWrt sources: /etc/openwrt_release, ubus system board

export PATH=/usr/sbin:/usr/bin:/sbin:/bin

THIS_SCRIPT="sysinfo"
MOTD_DISABLE=""

# show IPv4 for common interfaces
SHOW_IP_PATTERN='^(br|eth|en|wlan|wwan|usb|ppp|tun|tap|wg|lan|wan)[0-9A-Za-z_.-]*$'

[ -f /etc/default/motd ] && . /etc/default/motd
for f in $MOTD_DISABLE; do
	[ "$f" = "$THIS_SCRIPT" ] && exit 0
done

color_ok='\033[0;92m'
color_warn='\033[0;91m'
color_info='\033[0;94m'
color_reset='\033[0m'

print_kv() {
	# $1 key, $2 value, $3 color
	[ -n "$2" ] || return 0
	printf '%s:  %b%s%b\n' "$1" "${3:-$color_ok}" "$2" "$color_reset"
}

get_board_model() {
	# Prefer ubus, fallback to /tmp/sysinfo/model
	local m
	m="$(ubus call system board 2>/dev/null | jsonfilter -e '@.model' 2>/dev/null)"
	[ -n "$m" ] && { echo "$m"; return; }
	[ -f /tmp/sysinfo/model ] && cat /tmp/sysinfo/model && return
	echo "OpenWrt"
}

get_vendor_model() {
	# x86 only; may not exist on all targets
	local v p
	v="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null)"
	p="$(cat /sys/class/dmi/id/product_name 2>/dev/null)"
	[ -n "$v$p" ] && echo "$v $p" && return
	echo ""
}

get_cpu_model() {
	awk -F': ' '/model name/{print $2; exit}' /proc/cpuinfo 2>/dev/null
}

get_cpu_cores() {
	grep -c '^processor' /proc/cpuinfo 2>/dev/null
}

get_cpu_temp() {
	# Return like: 45.0°C (best-effort)
	local t
	for p in /sys/class/thermal/thermal_zone*/temp; do
		[ -f "$p" ] || continue
		t=$(cat "$p" 2>/dev/null)
		case "$t" in
			''|*[!0-9]*) continue ;;
		esac
		# most are milli-degree
		if [ "$t" -gt 1000 ] 2>/dev/null; then
			awk "BEGIN{printf \"%.1f°C\", $t/1000}" && return
		else
			echo "${t}°C" && return
		fi
	done
	echo ""
}

get_ip_addresses() {
	local ips intf tmp
	ips=""
	for intf in $(ls /sys/class/net 2>/dev/null); do
		echo "$intf" | grep -Eq "$SHOW_IP_PATTERN" || continue
		tmp=$(ip -4 addr show dev "$intf" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1)
		[ -n "$tmp" ] || continue
		ips="$ips $tmp"
	done
	echo "$ips" | awk '{$1=$1;print}'
}

get_uptime_human() {
	# Use /proc/uptime
	local up s m h d
	up=$(cut -d. -f1 /proc/uptime 2>/dev/null)
	[ -n "$up" ] || { echo ""; return; }
	s=$up
	d=$((s/86400)); s=$((s%86400))
	h=$((s/3600));  s=$((s%3600))
	m=$((s/60));    s=$((s%60))
	[ "$d" -gt 0 ] && printf '%d天 ' "$d"
	printf '%d小时 %d分钟' "$h" "$m"
}

get_load1() {
	awk '{print $1}' /proc/loadavg 2>/dev/null
}

mem_usage_percent() {
	# use free (busybox) output; best-effort
	free | awk 'NR==2{if($2>0){printf("%.0f",($3/$2)*100)}else{print 0}}'
}

mem_total_mb() {
	free | awk 'NR==2{printf("%d",$2/1024)}'
}

swap_usage_percent() {
	free | awk 'NR==3{if($2>0){printf("%.0f",($3/$2)*100)}else{print 0}}'
}

swap_total_mb() {
	free | awk 'NR==3{printf("%d",$2/1024)}'
}

df_usage() {
	# $1 mountpoint -> usage percent (without %)
	df -h "$1" 2>/dev/null | awk 'NR==2{gsub(/%/,"",$5);print $5}'
}

df_total() {
	# $1 mountpoint -> total
	df -h "$1" 2>/dev/null | awk 'NR==2{print $2}'
}

BOARD_MODEL="$(get_board_model)"
VENDOR_MODEL="$(get_vendor_model)"
CPU_MODEL="$(get_cpu_model)"
CPU_CORES="$(get_cpu_cores)"
CPU_TEMP="$(get_cpu_temp)"
KERNEL="$(uname -rs 2>/dev/null)"
UPTIME_H="$(get_uptime_human)"
LOAD1="$(get_load1)"
IPS="$(get_ip_addresses)"

MEM_P="$(mem_usage_percent)"
MEM_T="$(mem_total_mb)"
SWAP_P="$(swap_usage_percent)"
SWAP_T="$(swap_total_mb)"

ROOT_U="$(df_usage /)"; ROOT_T="$(df_total /)"

printf '设备信息： %s\n' "$BOARD_MODEL"
[ -n "$VENDOR_MODEL" ] && print_kv "制 造 商" "$VENDOR_MODEL" "$color_info"
print_kv "内核版本" "$KERNEL" "\033[0;33m"

if [ -n "$CPU_MODEL" ]; then
	if [ -n "$CPU_TEMP" ]; then
		print_kv "处 理 器" "${CPU_MODEL} (x${CPU_CORES}, ${CPU_TEMP})" "$color_warn"
	else
		print_kv "处 理 器" "${CPU_MODEL} (x${CPU_CORES})" "$color_warn"
	fi
fi

print_kv "系统负载" "${LOAD1}" "$color_ok"
print_kv "运行时间" "$UPTIME_H" "$color_ok"
print_kv "内存已用" "${MEM_P}% of ${MEM_T}MB" "$color_ok"
print_kv "交换内存" "${SWAP_P}% of ${SWAP_T}MB" "$color_ok"
print_kv "IP  地址" "$IPS" "$color_ok"
print_kv "系统存储" "${ROOT_U}% of ${ROOT_T}" "$color_ok"

echo

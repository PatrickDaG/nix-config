{
  lib,
  version,
  pkgs,
  ...
}:
with lib.kernel;
with (lib.kernel.whenHelpers version);
{
  patch = null;
  structuredExtraConfig = {
    # Necessary for BTF and crashkernel
    DEBUG_INFO = yes;
    DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT = whenAtLeast "5.18" yes;
    # Reduced debug info conflict with BTF and have been enabled in
    # aarch64 defconfig since 5.13
    DEBUG_INFO_REDUCED = whenAtLeast "5.13" (option no);
    DEBUG_INFO_BTF = option yes;
    # Allow loading modules with mismatched BTFs
    # FIXME: figure out how to actually make BTFs reproducible instead
    # See https://github.com/NixOS/nixpkgs/pull/181456 for details.
    MODULE_ALLOW_BTF_MISMATCH = whenAtLeast "5.18" (option yes);
    BPF_LSM = option yes;
    DEBUG_KERNEL = yes;
    DEBUG_DEVRES = no;
    DYNAMIC_DEBUG = yes;
    DEBUG_STACK_USAGE = no;
    RCU_TORTURE_TEST = no;
    SCHEDSTATS = yes;
    DETECT_HUNG_TASK = yes;
    CRASH_DUMP = yes;
    # Easier debugging of NFS issues.
    SUNRPC_DEBUG = yes;
    # Provide access to tunables like sched_migration_cost_ns
    SCHED_DEBUG = whenOlder "6.15" yes;

    # Count IRQ and steal CPU time separately
    IRQ_TIME_ACCOUNTING = yes;
    PARAVIRT_TIME_ACCOUNTING = yes;

    # Enable CPU lockup detection
    LOCKUP_DETECTOR = yes;
    SOFTLOCKUP_DETECTOR = yes;
    HARDLOCKUP_DETECTOR = lib.mkIf (
      with pkgs.stdenv.hostPlatform; isPower || isx86 || lib.versionAtLeast version "6.5"
    ) yes;

    # Enable streaming logs to a remote device over a network
    NETCONSOLE = module;
    NETCONSOLE_DYNAMIC = yes;

    # Export known printks in debugfs
    PRINTK_INDEX = whenAtLeast "5.15" yes;

    # Enable crashkernel support
    PROC_VMCORE = yes;
    HIGHMEM4G = lib.mkIf (pkgs.stdenv.hostPlatform.isx86 && pkgs.stdenv.hostPlatform.is32bit) (
      whenAtLeast "6.15" yes
    );

    # Track memory leaks and performance issues related to allocations.
    MEM_ALLOC_PROFILING = whenAtLeast "6.10" yes;
    MEM_ALLOC_PROFILING_ENABLED_BY_DEFAULT = whenAtLeast "6.10" yes;
  };
}

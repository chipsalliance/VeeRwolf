/*
 * Copyright (c) 2019 Western Digital Corporation or its affiliates
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <zephyr.h>
#include <device.h>
#include <sys/printk.h>
#include <disk_access.h>
#include <fs.h>
#include <ff.h>
#include <uart.h>

#define UART_DEVICE_NAME CONFIG_UART_CONSOLE_ON_DEV_NAME

static int lsdir(const char *path);

static FATFS fat_fs;
/* mounting info */
static struct fs_mount_t mp = {
	.type = FS_FATFS,
	.fs_data = &fat_fs,
};

static const char *disk_mount_pt = "/SD:";

int init_sd(void) {

  /* raw disk i/o */
  do {
    static const char *disk_pdrv = "SD";
    u64_t memory_size_mb;
    u32_t block_count;
    u32_t block_size;
    
    if (disk_access_init(disk_pdrv) != 0) {
      printk("Storage init ERROR!");
      break;
    }
    
    if (disk_access_ioctl(disk_pdrv,
			  DISK_IOCTL_GET_SECTOR_COUNT, &block_count)) {
      printk("Unable to get sector count");
      break;
    }

    if (disk_access_ioctl(disk_pdrv,
			  DISK_IOCTL_GET_SECTOR_SIZE, &block_size)) {
      printk("Unable to get sector size");
      break;
    }
    printk("Sector size %u\n", block_size);
    
    memory_size_mb = (u64_t)block_count * block_size;
    printk("Memory Size(MB) %u\n", (u32_t)memory_size_mb>>20);
  } while (0);
  
  mp.mnt_point = disk_mount_pt;
  
  int res = fs_mount(&mp);
  
  if (res == FR_OK) {
    printk("Disk mounted.\n");
    lsdir(disk_mount_pt);
  } else {
    printk("Error mounting disk.\n");
  }
  return 0;
}

static int lsdir(const char *path)
{
	int res;
	struct fs_dir_t dirp;
	static struct fs_dirent entry;

	/* Verify fs_opendir() */
	res = fs_opendir(&dirp, path);
	if (res) {
		printk("Error opening dir %s [%d]\n", path, res);
		return res;
	}

	printk("\nListing dir %s ...\n", path);
	for (;;) {
		/* Verify fs_readdir() */
		res = fs_readdir(&dirp, &entry);

		/* entry.name[0] == 0 means end-of-dir */
		if (res || entry.name[0] == 0) {
			break;
		}

		if (entry.type == FS_DIR_ENTRY_DIR) {
			printk(" [DIR ] %s\n", entry.name);
		} else {
			printk(" [FILE] %s (size = %zu)\n",
				entry.name, entry.size);
		}
	}

	/* Verify fs_closedir() */
	fs_closedir(&dirp);

	return res;
}

int match_file(char *filename) {
}  

void main(void)
{
  u8_t ver_rev   = sys_read8(0x80001000);
  u8_t ver_minor = sys_read8(0x80001001);
  u8_t ver_major = sys_read8(0x80001002);
  u8_t ver_dirty = sys_read8(0x80001003);

  u32_t ver_sha = sys_read32(0x80001004);

  printk("\nSweRVolf version %d.%d.%d (SHA %08x)\n",
	 ver_major,
	 ver_minor,
	 ver_rev,
	 ver_sha);

  printk("     __\n");
  printk("   []  []-o CHIPS\n");
  printk(" o-[]  []\n");
  printk("   []  []-o ALLIANCE\n");
  printk(" o-[]__[]\n\n");

  if (ver_dirty)
    printk("Warning! SweRVolf was built from a modified source tree\n");

  u8_t mem_status = sys_read8(0x8000100a);
  if (mem_status & 0x1)
    printk("Memory test completed %s\n", (mem_status & 2) ? "with errors" : "successfully");
  else
    printk("Warning! Memory test did not complete\n");

  //Exit simulation. No effect on hardware
  sys_write8(1, 0x80001009);

  init_sd();
  printk("Now proceeding to blink the LED\n");
  printk("Enter a filename to execute it\n");

  struct device *uart_dev = device_get_binding(UART_DEVICE_NAME);
  char c;
  char filename[16] = {0};
  int has_char;
  int fnidx = 0;
  while (1) {
    has_char = !uart_poll_in(uart_dev, &c);
    if (has_char) {
      //printk("%d\n", c);
      uart_poll_out(uart_dev, c);
      if ((c == '\n') || (c == '\r')) {printk("newline\n");
	break;}
      filename[fnidx++] = c;
    }
    
    /*    sys_write8(1, 0x80001010);
    k_sleep(1000);
    sys_write8(0, 0x80001010);
    k_sleep(1000);*/
  }
  printk("You chose %s\n", filename);
}

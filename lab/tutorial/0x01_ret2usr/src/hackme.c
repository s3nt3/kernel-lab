#include <linux/fs.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/miscdevice.h>
#include <linux/module.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Thomas Ting");
MODULE_DESCRIPTION("A simple kernel pwn challenge.");

#define SUCCESS 0

static char hackme_buf[0x1000];

/* Methods */

static int hackme_open(struct inode *inode, struct file *file)
{
    return SUCCESS;
}

static ssize_t hackme_read(struct file *filp, /* see include/linux/fs.h   */
                           char __user *buff, /* buffer to fill with data */
                           size_t length, /* length of the buffer     */
                           loff_t *offset)
{
    char tmp[0x80];

    memcpy(hackme_buf, tmp, length);

    if (length > 0x1000) {
        pr_alert("Buffer overflow detected (%d < %lu)!\n", 0x1000, length);
        BUG();
    }

    if (copy_to_user(buff, hackme_buf, length) != 0) {
        return -EINVAL;
    } else {
        return length;
    }
}

static ssize_t hackme_write(struct file *filp, const char __user *buff,
                            size_t length, loff_t *off)
{
    char tmp[0x80];

    if (length > 0x1000) {
        pr_alert("Buffer overflow detected (%d < %lu)!\n", 0x1000, length);
        BUG();
    }

    if (copy_from_user(hackme_buf, buff, length) != 0) {
        return -EINVAL;
    } else {
        memcpy(tmp, hackme_buf, length);
        pr_alert("Copy to stack success: tmp[0] = %c", tmp[0]);

        return length;
    }
}

static int hackme_release(struct inode *inode, struct file *file)
{
    return SUCCESS;
}

static struct file_operations hackme_fops = {
    .open = hackme_open,
    .read = hackme_read,
    .write = hackme_write,
    .release = hackme_release,
};

static struct miscdevice hackme_dev = {
    .minor    = MISC_DYNAMIC_MINOR,
    .name    = KBUILD_MODNAME,
    .fops    = &hackme_fops,
};

static int __init hackme_init(void)
{
    return misc_register(&hackme_dev);
}

static void __exit hackme_exit(void)
{
    /* Unregister the device */
    misc_deregister(&hackme_dev);
}

module_init(hackme_init);
module_exit(hackme_exit);

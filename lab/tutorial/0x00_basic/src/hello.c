/*
 * hello.c - Demonstrates module documentation.
 */
#include <linux/init.h> /* Needed for the macros */
#include <linux/kernel.h> /* Needed for pr_info() */
#include <linux/module.h> /* Needed by all modules */

MODULE_LICENSE("GPL");
MODULE_AUTHOR("LKMPG");
MODULE_DESCRIPTION("A simple kernel module.");

static int __init init_hello(void)
{
    pr_info("Hello, world\n");
    return 0;
}

static void __exit cleanup_hello(void)
{
    pr_info("Goodbye, world\n");
}

module_init(init_hello);
module_exit(cleanup_hello);

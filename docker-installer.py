import os
import subprocess
import threading
import time

def show_progress():
    spinstr = '|/-\\'
    idx = 0
    while True:
        print(f' [{spinstr[idx % len(spinstr)]}]', end='\r')
        idx += 1
        time.sleep(0.1)

def check_docker_installation():
    try:
        result = subprocess.run(['curl', '-fsSL', 'https://get.docker.com'], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return result.returncode == 0
    except subprocess.CalledProcessError as e:
        if e.returncode == 22 and "403" in e.stderr.decode():
            return False
        return True

def apply_dns_settings():
    subprocess.run(['sudo', 'bash', '-c', 'echo -e "\nDNS=dns.403.online\nDNSOverTLS=yes" >> /etc/systemd/resolved.conf && echo -e "nameserver 10.202.10.202\nnameserver 10.202.10.102" > /etc/resolv.conf && systemctl restart systemd-resolved'], check=True)

def install_docker():
    subprocess.run('curl -fsSL https://get.docker.com | sh', shell=True, check=True)

def configure_docker():
    os.makedirs('/etc/docker', exist_ok=True)
    with open('/etc/docker/daemon.json', 'w') as f:
        f.write('{\n  "registry-mirrors": ["https://docker.arvancloud.ir"]\n}')
    subprocess.run(['systemctl', 'daemon-reload'], check=True)
    subprocess.run(['systemctl', 'restart', 'docker'], check=True)

if __name__ == "__main__":
    progress_thread = threading.Thread(target=show_progress)
    progress_thread.daemon = True
    progress_thread.start()

    if not check_docker_installation():
        apply_dns_settings()
    
    install_docker()
    configure_docker()

    print("All tasks completed successfully.")

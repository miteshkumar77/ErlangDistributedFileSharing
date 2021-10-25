import sys
import time
import subprocess

def parse_line(line, subprocesses):
    print(' '.join(line))
    if line[0] == 'sleep':
        time.sleep(float(line[1]))       
    else:
        if line[0] == 'd':
            cmd = ['erl', '-noshell', '-detatched', '-sname', line[1], '-setcookie', 'foo', '-eval', 'main:start_dir_service()']
            subprocesses.append(subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE))
            time.sleep(1.0)
        elif line[0] == 'f':
            cmd = ['erl', '-noshell', '-detatched', '-sname', line[2], '-setcookie', 'foo', '-eval', f'main:start_file_server({line[1]})']
            subprocesses.append(subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE))
            time.sleep(1.0)
        elif line[0] == 'g':
            cmd = ['erl', '-sname', 'client@localhost', '-setcookie', 'foo', '-eval', f'main:get({line[1]}, {line[2]})']
            Proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
            time.sleep(1.0)
            Proc.kill()
        elif line[0] == 'c':
            cmd = ['erl', '-noshell', '-detatched', '-sname', 'client@localhost', '-setcookie', 'foo', '-eval', f'main:create({line[1]}, {line[2]})']
            Proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
            time.sleep(1.0)
            Proc.kill()
            time.sleep(1.0)
        elif line[0] == 'q':
            cmd = ['erl', '-noshell', '-detatched', '-sname', 'client@localhost', '-setcookie', 'foo', '-eval', f'main:quit({line[1]})']
            Proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
            time.sleep(1.0)
            Proc.kill()
            time.sleep(1.0)

def waitfor(procs):
    iters = 0
    while True:
        for proc in procs:
            print(proc.stdout.readline())
            proc.poll()
                
        if all(proc.returncode is not None for proc in procs):
            break
        iters += 1

        if iters > 20:
            print("ERROR: timeout...")
            for proc in procs:
                proc.kill()
            return
        time.sleep(.5)

def main():
    script_name = sys.argv[1]
    Proc = subprocess.Popen(['erlc', 'main.erl', 'util.erl', 'fileService.erl', 'dirService.erl'], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    waitfor([Proc])
    subprocesses = []
    with open(script_name, 'r') as script:
        for l in script:
            parse_line(l.strip().split(' '), subprocesses)

        waitfor(subprocesses)

if __name__ == "__main__":
    main()
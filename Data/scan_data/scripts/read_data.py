#! /usr/bin/env python

file = '/Users/vassiki/Desktop/CatPercep/Data/scan_data/S1B1Sc.asc'

def read_fixations(f,line):
    time = []; xpos = []; ypos = []
    while 'EFIX' not in line:
        info = line.split()
        print line
        time.append(info[0])
        xpos.append(info[1])
        ypos.append(info[2])
    data = [time,xpos,ypos]
    return data
    
def master():
    with open(file,'r') as f:

        trial_num = 0;
        fix_data = []

        line = f.readline()
        while line != '':
            if 'TRIALID' in line and not 'OVER' in line:
                trial_num += 1
                print 'Trial Number ' + str(trial_num)
                line = f.readline()
                while not 'TRIALID' in line and not 'OVER' in line:
                    if 'FIX ON' in line and not 'SEC' in line:
                        fix_num = 0; sacc_num = 0
                        print 'Fixation Cross is on'
                        #line = f.readline()
                        while 'FIX OFF' not in line:
                            if 'SFIX' in line:
                                fix_num += 1
                                data = read_fixations(f,line)
                                fix_data.append('Trial ' + str(trial_num))
                                fix_data.append('Fixation' + str(fix_num))
                                fix_data.append(data)
                            elif 'SSACC' in line:
                                sacc_num += 1
                                print 'Saccade Number ' + str(sacc_num)
                                line = f.readline() 
                            else:
                                line = f.readline() 
                    else:
                        line = f.readline()
            else:
                line = f.readline()
        return fix_data

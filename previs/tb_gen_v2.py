#coding=UTF-8

import shutil
import sys
import os

if "/" in sys.argv[1]:
    directory = ""
    for s in sys.argv[1].split("/")[:-1]:
        directory += s+"/"
    init_file_name = sys.argv[1].split("/")[-1]
else:
    directory = ""
    init_file_name = sys.argv[1]

print init_file_name

class Data(object):
    def __init__(self,Ports,library,entity):
        self.library = library
        self.entity = entity
        self.signals = dict()
        self.all_ports = []
        self.all_ports_c = []
        self.__ports = Ports
        for t in self.__ports.port_types:
            p_list = self.__ports.getPorts(t)
            o_dict = dict()
            for ports in p_list:
                if ports[1] in o_dict.keys():
                    temp = o_dict[ports[1]]
                    o_dict[ports[1]] = temp + ports[0]
                else:
                    o_dict[ports[1]] = ports[0]
                if ports[1] in self.signals.keys():
                    temp = self.signals[ports[1]]
                    self.signals[ports[1]] = temp + ports[0]
                else:
                    self.signals[ports[1]] = ports[0]
            if o_dict != {}:
                self.all_ports_c += [(t,o_dict)]
                for key in o_dict.keys():
                    for port in o_dict[key]:
                        self.all_ports += [port]

    def portLines(self):
        return self.__ports.port_lines

    def getPorts(self,p_type):
        return self.__ports[self.port_types.index(p_type)]

    def checkLoadedData(self):
        loaded_ports = False
        correct_ports_format = True
        for t in self.__ports.port_types:
            ports = self.__ports.getPorts(t)
            if ports != []:
                loaded_ports = True
                for port in ports:
                    if port[1].count("(") != port[1].count(")"):
                        correct_ports_format = False
                    for port_name in port[0]:
                        if port_name.count("(") != port_name.count(")"):
                            correct_ports_format = False
        if self.library != [] and self.entity != "" and loaded_ports and correct_ports_format:
            return True
        else:
            return False

    def getPossibleClocks(self):
        for t,ports in self.all_ports_c:
            if t == "in":
                for key in ports.keys():
                    if key.lower() == "std_logic":
                        return ports[key]
        return []

class Adjust(object):
    def __init__(self,line = ""):
        self.__line = line[:-1]

    def align(self,text = False):
        if not text:
            text = self.__line
        min_i = 0
        min_set = False
        max_i = len(text)
        for i in range(len(text)):
            if text[i] not in (" ","\t"):
                if not min_set:
                    min_i = i
                    min_set = True
                max_i = i+1
        return text[min_i:max_i]

    def cleanFileData(self,text = False):
        if not text:
            text = self.__line
        clean_line = ""
        for element in text.split("\n"):
            lim = None
            if "--" in element:
                lim = element.index("--")
            clean_line += element[:lim]
        return clean_line

    def cleanList(self,l):
        new_list = []
        for element in l:
            only_spaces = True
            for letter in element:
                if letter not in (" ","\t"):
                    only_spaces = False
            if not only_spaces:
                new_list += [element]
        return new_list

    def cleanSpaces(self,text = False):
        if not text:
            text = self.__line
        clean_line = ""
        for element in text:
            if element not in (" ","\t"):
                clean_line += element
        return clean_line

    def cleanCharacter(self, char, text=False):
        if not text:
            text = self.__line
        clean_line = ""
        for element in text:
            if element != char:
                clean_line += element
        return clean_line

class Ports(object):
    def __init__(self):
        self.port_types = ["in", "out", "inout", "buffer", "linkage"]
        self.port_lines = []
        self.__ports = [[],[],[],[],[]]

    def addLine(self,line):
        self.port_lines += [line]

    def getPorts(self,p_type):
        return self.__ports[self.port_types.index(p_type)]

    def processLines(self):
        adj = Adjust()
        for element in self.port_lines:
            port = element.split(":")
            port[0] = adj.cleanSpaces(port[0])
            port[1] = adj.align(port[1])
            temp = port[1].split()
            if "," in port[0]:
                port_names = port[0].split(",")
            else:
                port_names = [port[0]]
            if temp[0] not in self.port_types:
                return -2
            else:
                t = temp[0]
            port_type = ""
            for i in range(1,len(temp)):
                if i == len(temp)-1:
                    port_type += temp[i]
                else:
                    port_type += temp[i]+" "
            self.__ports[self.port_types.index(t)] += [(port_names,port_type)]

def readFile():
    try:
        f = open(sys.argv[1],"r")
    except:
        return -1
    adj = Adjust()
    entity = ""
    library_run = False
    library_end = False
    library_lines = []
    ports = Ports()
    port_run = False
    ended = False
    fileData = adj.cleanList(adj.cleanFileData(f.read()).split(";"))
    f.close()
    for element in fileData:
        element = adj.align(element)
        splitted_e = element.split()
        if not library_end and (splitted_e[0] == "library" or (splitted_e[0] == "use" and library_run)):
            library_lines += [splitted_e[0]+" "+splitted_e[1]+";"]
            library_run = True
        elif entity == "" and splitted_e[0] == "entity":
            library_run = False
            library_end = True
            entity = splitted_e[1]
            if element.count("(") > element.count(")"):
                ports.addLine(adj.align(adj.align(element.split("port")[1])[1:]))
                port_run = True
            else:
                ports.addLine(adj.align(adj.align(element.split("port")[1])[1:])[:-1])
        elif port_run:
            if element.count("(") < element.count(")"):
                ports.addLine(adj.align(element)[:-1])
                port_run = False
            else:
                ports.addLine(adj.align(element))
        elif element == "end "+entity:
            if ports.processLines() == -2:
                return -2
            data = Data(ports,library_lines,entity)
            ended = True
            break
    if not ended:
        return -3
    if data.checkLoadedData():
        return data
    else:
        return -2

def writeFile(data,clock_data):
    if "." in init_file_name:
        f = open(directory+init_file_name.split(".")[0]+"_tb.vhd","w")
    else:
        return -1
    for line in data.library:
        f.write(line+"\n")
    f.write("\n")
    f.write("entity {0} is\n".format(data.entity+"_tb"))
    f.write("end {0};\n".format(data.entity+"_tb"))
    f.write("\n")
    f.write("architecture behav of {0} is\n".format(data.entity+"_tb"))
    f.write("\tcomponent {0}\n".format("my_"+data.entity))
    f.write("\tport( ")
    first_port_line = True
    for i in range(len(data.all_ports_c)):
        t,ports = data.all_ports_c[i]
        for k in range(len(ports.keys())):
            key = ports.keys()[k]
            port_names = ""
            for j in range(len(ports[key])):
                if j == len(ports[key])-1:
                    port_names += ports[key][j]
                    if i == len(data.all_ports_c)-1 and k == len(ports.keys())-1:
                        line_end = ");"
                    else:
                        line_end = ";"
                else:
                    port_names += ports[key][j]+", "
            if first_port_line:
                start_spaces = 0
                first_port_line = False
            else:
                start_spaces = len("\tport( ")+1
            f.write("{0} : {1} {2}\n".format(" "*start_spaces+port_names,t,key+line_end))
    f.write("\tend component;\n")
    f.write("\tfor dut : {0} use entity work.{1};\n".format("my_"+data.entity,data.entity))
    f.write("\n")
    for key in data.signals.keys():
        port_names = ""
        ports = data.signals[key]
        for i in range(len(ports)):
            if i == len(ports)-1:
                port_names += ports[i]
            else:
                port_names += ports[i]+", "
        f.write("\tsignal {0} : {1};\n".format(port_names,key))
    f.write("\n")
    f.write("begin\n")
    f.write("\n")
    p_m_line = "dut : "+"my_"+data.entity+" port map ( "
    f.write(p_m_line)
    first_port_line = True
    for i in range(len(data.all_ports)):
        port = data.all_ports[i]
        if i == len(data.all_ports)-1:
            line_end = ");"
        else:
            line_end = ","
        if first_port_line:
            start_spaces = 0
            first_port_line = False
        else:
            start_spaces = len(p_m_line)
        f.write("{0} => {1}\n".format(" "*start_spaces+port,port+line_end))
    f.write("\n")
    if clock_data:
        for i in range(len(clock_data)):
            var_name, time, cycles = clock_data[i]
            f.write("clk{0}_process: process\n".format(str(i)))
            f.write("\tbegin           --the clock process\n")
            f.write("\t\t{0} <= '0';\n".format(var_name))
            f.write("\t\twait for {:.20f} ms;\n".format((time*1000)/2))
            f.write("\t\tfor i in 1 to {0} loop\n".format(str(cycles*2)))
            f.write("\t\t\t{0} <= not {0};\n".format(var_name))
            f.write("\t\t\twait for {:.20f} ms;\n".format((time*1000)/2))
            f.write("\t\tend loop;\n")
            f.write("\t\twait;\n")
            f.write("end process clk{0}_process;\n".format(str(i)))
            f.write("\n")
    f.write("process\n")
    f.write("\tbegin\n")
    f.write("\t\twait;\n")
    f.write("\t-- Enter here your simulation sequence\n")
    f.write("end process;\n")
    f.write("end behav;\n")
    f.close()

def main_readParams(d):
    print
    print "Library lines:"
    print
    for line in d.library:
        print "   ->",line
    print
    print "New Entity name:",d.entity+"_tb"
    print
    for t,ports in d.all_ports_c:
        if ports != {}:
            print t.capitalize()+" ports:"
            for key in ports.keys():
                values = ""
                for e in ports[key]:
                    if values == "":
                        values += e
                    else:
                        values += ", "+e
                print "   ->",values,":",key
        print

def main_manualClock(d,possible_names,can_auto,repeat):
    adj = Adjust()
    while True:
        if repeat:
            s = "s"
        else:
            print
            if can_auto:
                s = raw_input("> Vols crear un clock definit manualment? [s/N] ")
            else:
                s = raw_input("> No s'ha pogut localitzar el clock automàticament. Vols crear un clock definit manualment? [s/N] ")
        if s.lower() == "s":
            if possible_names != []:
                while True:
                    if len(possible_names) == 1:
                        var_name = possible_names[0]
                    else:
                        print
                        var_name = raw_input("~ Selecciona un dels ports d'entrada {0}: ".format(str(possible_names)))
                        if var_name.isdigit():
                            var_name = possible_names[int(var_name)]
                        elif '"' in var_name or "'" in var_name:
                            var_name = adj.cleanCharacter(var_name,"'")
                            var_name = adj.cleanCharacter(var_name,'"')
                    if var_name in possible_names:
                        while True:
                            print
                            fq = raw_input("~ Introdueix el període (s) o frequencia (Hz) [Exemple: 300Hz]: ").lower()
                            if "s" not in fq and "hz" not in fq:
                                print
                                print "!ERROR! Entrada incorrecta. Recorda de introduir la unitat de mesura. Torna a provar."
                            else:
                                try:
                                    if "s" in fq:
                                        time = float(fq[:fq.index("s")])
                                    else:
                                        time = 1/float(fq[:fq.index("hz")])
                                    break
                                except:
                                    print
                                    print "!ERROR! Entrada incorrecta. Recorda de introduir la unitat de mesura. Torna a provar."
                        del possible_names[possible_names.index(var_name)]
                        while True:
                            print
                            c = raw_input("~ Introdueix el nombre de cicles: ").lower()
                            if not c.isdigit():
                                print
                                print "!ERROR! Entrada incorrecta. Torna a provar."
                            else:
                                cycles = int(c)
                                break
                        return (var_name,time,cycles)
                    else:
                        print
                        print "!ERROR! Entrada incorrecta. Torna a provar."
            else:
                print
                print "!ERROR! No s'ha detectat cap variable que pugui ser un clock. No es crearà cap clock."
                return False
        elif s.lower() == "n" or s == "":
            return False
        else:
            print
            print "!ERROR! Entrada incorrecta. Torna a provar."

def main_autoclock(d, possible_names):
    if "clk" in d.all_ports:
        var_name = "clk"
    else:
        var_name = "clock"
    while True:
        print
        fq = raw_input("~ Introdueix el període (s) o frequencia (Hz) [Exemple: 300Hz]: ").lower()
        if "s" not in fq and "hz" not in fq:
            print
            print "!ERROR! Entrada incorrecta. Recorda de introduir la unitat de mesura. Torna a provar."
        else:
            try:
                if "s" in fq:
                    time = float(fq[:fq.index("s")])
                else:
                    time = 1/float(fq[:fq.index("hz")])
                break
            except:
                print
                print "!ERROR! Entrada incorrecta. Recorda de introduir la unitat de mesura. Torna a provar."
    del possible_names[possible_names.index(var_name)]
    while True:
        print
        c = raw_input("~ Introdueix el nombre de cicles: ").lower()
        if not c.isdigit():
            print
            print "!ERROR! Entrada incorrecta. Torna a provar."
        else:
            cycles = int(c)
            break
    return (var_name,time,cycles)

def main_writeParams(d):
    possible_names = d.getPossibleClocks()[:]
    i = len(possible_names)
    clock_info = False
    print
    if "clk" in d.all_ports or "clock" in d.all_ports:
        while True:
            s = raw_input("> S'ha detectat una variable de clock. Vols crear un clock automàtic? [S/n] ")
            if s.lower() == "s" or s == "":
                clock_info = [main_autoclock(d,possible_names)]
                i -= 1
                break
            elif s.lower() == "n":
                manual_init = main_manualClock(d,possible_names,False,False)
                if not manual_init:
                    clock_info = manual_init
                else:
                    clock_info = [manual_init]
                    i -= 1
                    print
                    while i > 0:
                        print
                        s = raw_input("> Encara queden variables que poden ser clocks. Vols crear un clock adicional? [s/N]")
                        if s.lower() == "s":
                            clock_info += [main_manualClock(d,possible_names,True,True)]
                            i -= 1
                        elif s.lower() == "n" or s == "":
                            break
                        else:
                            print
                            print "!ERROR! Entrada incorrecta. Torna a provar."
                break
            else:
                print
                print "!ERROR! Entrada incorrecta. Torna a provar."
    else:
        manual_init = main_manualClock(d,possible_names,False,False)
        if not manual_init:
            clock_info = manual_init
        else:
            clock_info = [manual_init]
            i -= 1
            print
            while i > 0:
                print
                s = raw_input("> Encara queden variables que poden ser clocks. Vols crear un clock adicional? [s/N]")
                if s.lower() == "s":
                    clock_info += [main_manualClock(d,possible_names,True,True)]
                    i -= 1
                elif s.lower() == "n" or s == "":
                    break
                else:
                    print
                    print "!ERROR! Entrada incorrecta. Torna a provar."
    print
    print
    print "# Definició de clocks completada"
    print
    print
    writeFile(d,clock_info)
    try:
        writeFile(d,clock_info)
        print "[ COMPLETE ] Test Bench generat correctament."
        print "Revisa l'arxiu generat per a completar la sequència de valors de les entrades."
        print
        return True
    except:
        print "!ERROR! No ha estat possible crear l'arxiu."
        print
        return False

def main_Simulate():
    print
    while True:
        s = raw_input("Vols executar la simulació? [s/N] ")
        if s == "s":
            print
            raw_input("Un cop afegida (si escau) la sequència de simulació a l'arxiu prem enter...").lower()
            print
            tb = init_file_name.split(".")[0]+"_tb"
            new_folder_name = init_file_name.split(".")[0]+"_simulation"
            if directory != "":
                os.chdir(directory)
            if os.path.isdir(new_folder_name):
                os.system("rm -rf {0}".format(new_folder_name))
            os.mkdir(new_folder_name)
            shutil.copyfile("./"+init_file_name, "./"+new_folder_name+"/"+init_file_name)
            shutil.copyfile("./"+tb+".vhd", "./"+new_folder_name+"/"+tb+".vhd")
            os.remove("./"+tb+".vhd")
            os.chdir(new_folder_name)
            os.system("ghdl -a {0}".format(init_file_name))
            os.system("ghdl -a {0}.vhd".format(tb))
            os.system("ghdl -e {0}".format(tb))
            os.system("ghdl -r {0} --vcd={0}.vcd".format(tb))
            os.system("gtkwave {0}.vcd".format(tb))
            break
        if s == "n" or s == "":
            break
        else:
            print
            print "!ERROR! Entrada incorrecta. Torna a provar."

    while True:
        s2 = raw_input("Vols crear un arxiu .py que executi la simulació? [S/n] ").lower()
        print
        if s2 == "s" or s2 == "":
            try:
                writeSimulation(init_file_name, tb)
                print "Fitxer escrit correctament. Executa 'pyhton simulate.py' per a visualitzar el simulador."
            except:
                print "!ERROR! No s'ha pogut crear l'arxiu."
            break
        if s2 == "n":
            break
        else:
            print "!ERROR! Entrada incorrecta. Torna a provar."
            print
    print

def writeSimulation(init_file_name, tb):
    f = open("simulate.py", "w")
    f.write("#coding=UTF-8\n\n")
    f.write("import os\n\n")
    f.write("def main():\n")
    f.write("\tos.system('ghdl -a {0}')\n".format(init_file_name))
    f.write("\tos.system('ghdl -a {0}.vhd')\n".format(tb))
    f.write("\tos.system('ghdl -e {0}')\n".format(tb))
    f.write("\tos.system('ghdl -r {0} --vcd={0}.vcd')\n".format(tb))
    f.write("\tos.system('gtkwave {0}.vcd')\n\n".format(tb))
    f.write("if __name__ == '__main__':\n")
    f.write("\tmain()\n")

def main():
    os.system("clear")
    complete_read = False
    try:
        d = readFile()
        c = True
    except:
        print
        print "!ERROR! Error llegint el codi. Comprova la sintaxi i torna a provar."
        print
        c = False

    if c:
        if d == -1:
            print
            print "!ERROR! No ha estat possible trobar l'arxiu"
            print
        elif d == -2:
            print
            print "!ERROR! Error identificant els ports. Comprova l'arxiu i torna a provar."
            print
        elif d == -3:
            print
            print "!ERROR! No s'ha trobat el final de l'entitat.  Comprova l'arxiu i torna a provar."
            print
        else:
            main_readParams(d)
            complete_read = True

    if complete_read:
        if main_writeParams(d):
            main_Simulate()


if __name__ == '__main__':
    main()

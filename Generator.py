import datetime

from faker import Faker

faker = Faker("pl_PL")

Faker.seed("bazy")

def customersGen(f,faker):
    customerAmount = faker.random.randint(20,40)
    pIList = []
    companiesList = []
    for i in range(1, customerAmount+1):
        if faker.random.randint(0,1) == 0:
            f.write( "proc_new_private_individual \""+ faker.first_name()+"\", \""+ faker.last_name()+"\", \""+ faker.numerify(text='#########')+"\"\n")
            f.write("GO\n")
            pIList.append(i);
        else:
            f.write( "proc_new_company \""+ faker.company()+ "\", \""+ faker.numerify(text='#########')+"\"\n")
            f.write("GO\n")
            companiesList.append(i)
    return (customerAmount, pIList, companiesList)

def attendeesGen(f,faker, customerAmount):
    attendeesAmount = faker.random.randint(5*customerAmount,6*customerAmount)
    customerAttendees = [[] for i in range(customerAmount+1)]
    for i in range(1,attendeesAmount):
        customerID = faker.random.randint(1,customerAmount)
        customerAttendees[customerID].append(i)
        f.write("proc_new_attendee "+ str(customerID)+ ", \""+ faker.first_name()+ "\", \""+ faker.last_name()+"\", "+ str(faker.random.randint(0,1))+ "\n")
        f.write("GO\n")
    return (attendeesAmount, customerAttendees)

def genConference(f,faker, maxAmount):
    conferenceAmount = faker.random.randint(110,120)
    conferenceStart = [0]
    conferenceEnd = [0]
    last = datetime.date(2017,1,1)
    for i in range(1,conferenceAmount):
        last = last + datetime.timedelta(days = faker.random.randint(1,16))
        start = last
        conferenceStart.append(last)
        last = last + datetime.timedelta(days = faker.random.randint(1,5))
        f.write("proc_new_conference \""+faker.bs()+"\", \""+ start.isoformat()+ "\", \""+ last.isoformat()+"\"\n")
        f.write("GO\n")
        conferenceEnd.append(last)

    return (conferenceAmount, conferenceStart, conferenceEnd)

def genConfDay(f,faker,conferenceAmount ,conferenceStart,conferenceEnd):
    conferenceDays = []
    for i in range(1,conferenceAmount):
        last = conferenceStart[i]
        while(last <= conferenceEnd[i]):
            limit = faker.random.randint(20,30)
            conferenceDays.append((last, limit))
            f.write("proc_new_conference_day "+str(i)+", \""+ last.isoformat()+ "\", "+ str(limit) +", "+str(faker.random.randint(50,100)) +"\n")
            f.write("GO\n")
            last = last + datetime.timedelta(days = faker.random.randint(1,2))
    return conferenceDays

def genWorkshops(f, faker, conferenceDays):
    dayWorkshops = {}
    wID = 0
    for day in conferenceDays:
            amount = faker.random.randint(3,7)
            dayWorkshops[day[0]] = []
            for i in range(amount):

                time = faker.time_object()
                while(time.hour>19): time = faker.time_object()

                endTime = (datetime.datetime.combine(datetime.date.today(), time) + datetime.timedelta(minutes=faker.random.randint(60, 120))).time()
                wID +=1
                dayWorkshops[day[0]].append([time,endTime,faker.random.randint(20,30), wID])
                f.write("proc_new_workshop \""+ day[0].isoformat()+ "\", \""+ time.isoformat()+
                      "\", \""+ endTime.isoformat()+"\", " +str(faker.random.randint(20,50))+", "
                        +str(dayWorkshops[day[0]][i][2])+", \""+faker.bs()+ "\" \n")
                f.write("GO\n")
    return dayWorkshops


def genReservations(f,faker,conferenceDays,dayWorkshops, customerAttendees):
    customerRes = []
    customerRes.append(None)

    resCusID = 0
    resAttID = 0
    for i in range(1,len(conferenceDays)):
        day = conferenceDays[i]
        n = 0
        customersUsed = set();
        while(n<day[1]):

            customerID = faker.random.randint(1,len(customerAttendees)-1)
            k = 0
            while(customersUsed.__contains__(customerID)):
                k+=1
                customerID = faker.random.randint(1, len(customerAttendees) - 1)
                if(k>10):
                    break
            if(k>10): break
            customersUsed.add(customerID)
            if(len(customerAttendees[customerID])==0): continue

            resCusID += 1
            custAttAm = faker.random.randint(1, len(customerAttendees[customerID]))
            custAttAm = min(custAttAm, day[1]-n)
            n+=custAttAm;
            resTime = (day[0] - datetime.timedelta(days=faker.random.randint(7, 30)))
            f.write("proc_new_customer_conference_day_reservation \""+ day[0].isoformat()+"\", "+str(customerID)+", "+ str(custAttAm)+
                  ", \""+ resTime.isoformat()+ "\", "+"1"+"\n")
            f.write("GO\n")
            for j in range(0,custAttAm):
                #print(customerAttendees)
                att = customerAttendees[customerID][j]
                f.write("proc_new_attendee_conference_day_reservation "+ str(att)+ ", "+ str(resCusID) +"\n")
                f.write("GO\n")
                resAttID += 1
                for wshop in dayWorkshops[day[0]]:
                    if(wshop[2]>0):
                        f.write("proc_new_workshop_attendee_reservation "+str(resAttID) +", "+str(wshop[3])+", "+"1"+"\n")
                        f.write("GO\n")
                        wshop[2] -= 1
                        break;


f = open("data.sql","w+")
(amount, pi, com) = customersGen(f,faker)
(attendeesAmount, customerAttendees) = attendeesGen(f,faker,amount)
(conferenceAmount, conferenceStart, conferenceEnd) = genConference(f,faker, 30)
conferenceDays = genConfDay(f,faker,conferenceAmount,conferenceStart,conferenceEnd)
dayWorkshops = genWorkshops(f,faker,conferenceDays)
genReservations(f,faker,conferenceDays, dayWorkshops,customerAttendees )
f.flush()
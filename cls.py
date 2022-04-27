class mobile :
    def __init__(self, number ):
        self.number = number
        
    def turn_on(self ):
        print('mobile phone {number} is turned on.'.format(number = self.number))
        
    
    def turn_off(self ):
        print('mobile phone {number} is turned off'.format(number = self.number))
        
    def call(self, number):
        print('calling {number}'.format(number = number))
        

mobile1 = mobile(number = '01832-96004')
mobile2 = mobile(number = '01832-96012')

Mobile = [mobile1,mobile2]

for x in Mobile:
    x.turn_on()
    x.call(number ='311-976-0998')


for x in Mobile:
    x.turn_off()

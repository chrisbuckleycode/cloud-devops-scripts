from datetime import datetime

print('Loading function')

def lambda_handler(event, context):
    print('## EVENT')
    print(event)
    print('Function run at {}'.format(str(datetime.now())))
    result = "Hello World"
    return {
        'statusCode' : 200,
        'body': result
    }

import sys
import os
from anthropic import Anthropic

api_key = os.environ.get('ANTHROPIC_API_KEY')

if not api_key:
	print("Set ANTHROPIC_API_KEY env variable")
	sys.exit(1)

anthropic = Anthropic(api_key=api_key)

def ask_anthropic(question):
	try:
		message = anthropic.messages.create(
			model="claude-3-sonnet-20240229",
			max_tokens=1000,
			messages=[
				{'role': 'user', 'content': question}
			]
		)
		return message.content[0].text
	except Exception as e:
		return f"Error: {str(e)}"


if __name__ == '__main__':
	if len(sys.argv) < 2:
		print("Usage: ai Your Question Here")
		sys.exit(1)

	question = ' '.join(sys.argv[1:])
	answer = ask_anthropic(question)
	print(answer)
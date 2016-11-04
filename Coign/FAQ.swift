//
//  FAQ.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/3/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation

struct FAQ {
    //properties
    let question: String!
    let answer: String!
}

let FAQs: [FAQ] = [
    FAQ(question: "What proption of my donation goes directly to the charity?", answer: "97%, at the moment. We hope to shape out business plan so that 100% of donation money reaches your charity of choice in the future."),
    FAQ(question: "How do I know that my financial information is safe?", answer: "Specialist 3rd party vendors secure all account verification and transactions, meaning that the only people who see you bank and credit card info are you and your bank."),
    FAQ(question: "What happens if my Facebook is hacked? Would my account details be vulnerable?", answer: "The short answer is no. The only way your account could be accessed by someone other than you is if someone stole your phone, hacked your facebook, and then somehow discovered your private PIN. All of that effort would leave a hacker without any of your financial information, and able only to make single dollar donations in your name. In that highly unlikely event, simply contacting the Coign team within a week of losing your phone would allow us to prevent any charge transfers."),
    FAQ(question: "This is cool, how can I help promote this?", answer: "There are two ways, and first is easy: participate at opportune moments moments in your life, and choose to share your message on Facebook. Donating doesn't have to be a difficult and impersonal process, but our platform depends on the social nature of altruism. The more people involved, the larger impact the Coign community has, and the more our team can progress our larger mission. The second is be vocal about any criticisms you have. We want to get better, and understand that the community as a whole will always be better at problem solving that us alone. The more feedback we get, the more we can build a product that people love."),
    FAQ(question: "Is there any way I could be involved?", answer: "If you have the technical skills to dramatically improve our team, the vision to help grow our team, and the ability to tolerate working with our team, feel free to get in contact. And coding skills or not, refering the previous question is always a good way to help."),
    FAQ(question: "Coign's intentions seem noble, but I am skeptical of any use cases where this would practically fit into my life.", answer: "Part of a startup's growing pains is finding how to adjust the product so that it fits perfectly into its users lives. So while we intend this app to be used in conjunction with Facebook posts relevant to some area of donation (disaster relief, healthcare, animal rights, environmental protection), to really drive home the point of putting action behind your words, the only people that can tell us the use cases or our failure to acccomodate them is you. So please leave us any feedback at all, because we would love to hear about ways to improve your experience."),
    FAQ(question: "I can think of a dozen applications of your platform better than donating mobile dollars. Why the myopic approach?", answer: "We agree, and have plans to improve as our user base grows. If you have any ideas in particular, we'd love to hear the feedback.")
]

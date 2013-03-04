/** Wraps the provided controller in a navigation controller. */
#define NAVIFY(controller) [[UINavigationController alloc] initWithRootViewController:controller]

/** Creates an NSURL out of the provided string. */
#define URLIFY(urlString) [NSURL URLWithString:urlString]

/** Formats a string */
#define F(string, args...) [NSString stringWithFormat:string, args]

/** Helper to create a quick UIAlertView with a title & message.  Contains a single OK button. */
#define ALERT(title, msg) [[[UIAlertView alloc] initWithTitle:title\
                                                      message:msg\
                                                     delegate:nil\
                                            cancelButtonTitle:@"OK"\
                                            otherButtonTitles:nil] show]
_filter = import_module("./filter.star")


# from_string creates a file artifact from a static string
def from_string(plan, path, contents, artifact_name=None, description=None):
    escaped_contents = _escape_template(contents)

    kwargs = _filter.remove_none({"name": artifact_name, "description": description})

    return plan.render_templates(
        config={
            path: struct(
                template=escaped_contents,
                data={},
            ),
        },
        **kwargs,
    )


# _escape_template turns a static string into a Go template that renders to exactly that string.
#
# Replacing "{{" and "}}" with escaped actions is not enough: a "{" right before "}}" (e.g. the JSON "{}}}")
# glues onto the escape action and yields "{{{ ...", which Go cannot parse. Instead, the whole string is emitted
# as Go raw string literals, inside which no delimiter is interpreted. Raw strings cannot contain backticks,
# so the string is split on "`" and each backtick is emitted as the action {{"`"}}.
def _escape_template(contents):
    # Without braces there is nothing Go could read as an action
    if "{" not in contents and "}" not in contents:
        return contents

    return '{{"`"}}'.join(["{{`" + segment + "`}}" for segment in contents.split("`")])

﻿/// <reference path="../../../../typings/bundle.d.ts" />

import Application = require('../../../models/application');
import APIResponse = require('../../api-response');
import Circle = require('../../../models/circle');
import User = require('../../../models/user');

var authorize = require('../../auth');

var circleShow = (req: any, res: APIResponse) => {
	authorize(req, res, (user: User, app: Application) => {

	});
}

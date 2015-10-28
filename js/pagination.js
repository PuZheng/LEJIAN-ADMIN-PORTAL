// implement http://flask.pocoo.org/snippets/44/ in js

function Pagination(options) {
    'use strict';

    this.page = parseInt(options.page);
    this.perPage = parseInt(options.perPage);
    this.totalCnt = parseInt(options.totalCnt);

    this.leftEdge = parseInt(options.leftEdge) || null;
    this.rightEdge = parseInt(options.rightEdge) || null;
    this.leftCurrent = parseInt(options.leftCurrent) || null;
    this.rightCurrent = parseInt(options.rightCurrent) || null;
}

Pagination.prototype.pageNo = function () {
    return Math.ceil(this.totalCount / this.perPage);
};


Pagination.prototype.hasPrev = function () {
    return this.page > 1;
};

Pagination.prototype.hasNext = function () {
    return this.page < this.pageNo();
};


Pagination.prototype.iterPage = function (cb) {
    var last = 0;
    for (var i = 1; i < this.pageNo() + 1; ++i) {
        if ((this.leftEdge === null || i < this.leftEdge) ||
           (this.rightEdge === null || i > this.pageNo() - this.rightEdge) ||
           ((this.leftCurrent === null || i >= this.page - this.leftCurrent) &&
           (this.rightCurrent === null || i < this.page + this.rightCurrent))) {
            if (last + 1 != i) {
                cb(null);
            } else {
                cb(i);
            }
            last = i;
        }
    }
};

Pagination.prototype.toJSON = function () {

    var pages = [];
    this.iterPage(function (i) {
        pages.push(i);
    });
    return {
        page: this.page,
        pageNo: this.pageNo(),
        hasPrev: this.hasPrev(),
        hasNext: this.hasNext(),
        pages: pages,
    };
};

module.exports = Pagination;

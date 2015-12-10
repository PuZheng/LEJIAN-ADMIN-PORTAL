// implement http://flask.pocoo.org/snippets/44/ in js

function Pagination(options) {
    'use strict';

    this.currentPage = parseInt(options.currentPage);
    this.perPage = parseInt(options.perPage);
    this.totalCount = parseInt(options.totalCount);

    this.leftEdge = parseInt(options.leftEdge) || null;
    this.rightEdge = parseInt(options.rightEdge) || null;
    this.leftCurrent = parseInt(options.leftCurrent) || null;
    this.rightCurrent = parseInt(options.rightCurrent) || null;
}

Pagination.prototype.pageNo = function () {
    return Math.ceil(this.totalCount / this.perPage);
};


Pagination.prototype.hasPrev = function () {
    return this.currentPage > 1;
};

Pagination.prototype.hasNext = function () {
    return this.currentPage < this.pageNo();
};


Pagination.prototype.iterPage = function (cb) {
    var last = 0;
    for (var i = 1; i < this.pageNo() + 1; ++i) {
        if ((this.leftEdge === null || i < this.leftEdge) ||
           (this.rightEdge === null || i > this.pageNo() - this.rightEdge) ||
           ((this.leftCurrent === null || i >= this.currentPage - this.leftCurrent) &&
           (this.rightCurrent === null || i < this.currentPage + this.rightCurrent))) {
            if (last + 1 != i) {
                cb('');
            } else {
                cb(i);
            }
            last = i;
        }
    }
};

Pagination.prototype.pages = function () {
    var ret = [];
    this.iterPage(function (i) {
        ret.push(i);
    });
    return ret;
};

Pagination.prototype.toJSON = function () {

    var pages = [];
    this.iterPage(function (i) {
        pages.push(i);
    });
    return {
        currentPage: this.currentPage,
        pageNo: this.pageNo(),
        hasPrev: this.hasPrev(),
        hasNext: this.hasNext(),
        pages: pages,
    };
};

module.exports = Pagination;
